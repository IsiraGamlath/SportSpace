const Maintenance = require('../models/Maintenance');
const Slot = require('../models/Slot');

const mockMaintenance = [
  {
    facilityName: 'Badminton Court 2',
    facilityType: 'Badminton',
    issue: 'Clean, marked and fully playable',
    priority: 'low',
    status: 'available',
    notes: 'No reported issues. Clean, marked and fully playable.',
  },
  {
    facilityName: 'Tennis Court 1',
    facilityType: 'Tennis',
    issue: 'Net damaged',
    priority: 'medium',
    status: 'required',
    notes: 'Reported Today, 9:20 AM. Tension cable broken.',
  },
  {
    facilityName: 'Swimming Pool',
    facilityType: 'Swimming Pool',
    issue: 'Routine filtration & chlorination window',
    priority: 'medium',
    status: 'scheduled',
    scheduledRepairTime: '8:00 AM – 10:00 AM',
    notes: 'Routine water filtration & chemical treatment window.',
  },
];

const formatMaintenance = (item) => {
  const obj = item.toObject ? item.toObject() : { ...item };
  obj.id = obj._id.toString();
  return obj;
};

// Seed initial maintenance flags
exports.seedMaintenance = async () => {
  try {
    const count = await Maintenance.countDocuments();
    if (count === 0) {
      await Maintenance.insertMany(mockMaintenance);
      console.log('Database seeded with mock maintenance flags');

      // Auto-block any existing slots for facilities marked required or scheduled
      const activeFlags = await Maintenance.find({
        status: { $in: ['required', 'scheduled'] },
      });

      for (const flag of activeFlags) {
        const slotsToBlock = await Slot.find({
          courtName: flag.facilityName,
          status: 'available',
        });

        if (slotsToBlock.length > 0) {
          const slotIds = slotsToBlock.map((s) => s._id);
          await Slot.updateMany(
            { _id: { $in: slotIds } },
            {
              $set: {
                status: 'blocked',
                blockedReason: `${flag.facilityName} — Under Maintenance`,
                maintenanceId: flag._id,
              },
            }
          );
          flag.affectedSlots = slotIds;
          await flag.save();
        }
      }
    }
  } catch (err) {
    console.error('Error seeding maintenance:', err);
  }
};

// GET /api/maintenance
// Get all maintenance flags (filterable by status, facilityName, priority)
exports.getMaintenanceFlags = async (req, res) => {
  try {
    const { status, facilityName, priority } = req.query;
    const query = {};

    if (status) query.status = status;
    if (facilityName) query.facilityName = facilityName;
    if (priority) query.priority = priority;

    const items = await Maintenance.find(query)
      .populate('affectedSlots')
      .sort({ createdAt: -1 });

    res.status(200).json(items.map(formatMaintenance));
  } catch (error) {
    res.status(500).json({ message: 'Error fetching maintenance flags', error: error.message });
  }
};

// GET /api/maintenance/overview/summary
exports.getMaintenanceSummary = async (req, res) => {
  try {
    const total = await Maintenance.countDocuments();
    const required = await Maintenance.countDocuments({ status: 'required' });
    const scheduled = await Maintenance.countDocuments({ status: 'scheduled' });
    const available = await Maintenance.countDocuments({ status: { $in: ['available', 'resolved'] } });

    res.status(200).json({
      total,
      required,
      scheduled,
      available,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching summary', error: error.message });
  }
};

// GET /api/maintenance/:id
exports.getMaintenanceById = async (req, res) => {
  try {
    const { id } = req.params;
    const flag = await Maintenance.findById(id).populate('affectedSlots');
    if (!flag) {
      return res.status(404).json({ message: 'Maintenance flag not found' });
    }
    res.status(200).json(formatMaintenance(flag));
  } catch (error) {
    res.status(500).json({ message: 'Error fetching maintenance flag', error: error.message });
  }
};

// POST /api/maintenance (Create maintenance flag)
// Business rule: If status is 'required' or 'scheduled', automatically block facility slots
exports.createMaintenanceFlag = async (req, res) => {
  try {
    const {
      facilityName,
      facilityType = 'Court',
      issue,
      priority = 'medium',
      status = 'required',
      scheduledRepairTime = null,
      notes = '',
      reportedBy = 'Manager',
    } = req.body;

    if (!facilityName || !issue) {
      return res.status(400).json({
        message: 'Missing required maintenance fields: facilityName and issue are required',
      });
    }

    const flag = new Maintenance({
      facilityName,
      facilityType,
      issue,
      priority,
      status,
      scheduledRepairTime,
      notes,
      reportedBy,
    });

    // Auto-block available facility slots if under maintenance
    if (status === 'required' || status === 'scheduled') {
      const slotsToBlock = await Slot.find({
        courtName: facilityName,
        status: { $in: ['available', 'pending'] },
      });

      if (slotsToBlock.length > 0) {
        const slotIds = slotsToBlock.map((s) => s._id);
        await Slot.updateMany(
          { _id: { $in: slotIds } },
          {
            $set: {
              status: 'blocked',
              blockedReason: `${facilityName} — Under Maintenance: ${issue}`,
              maintenanceId: flag._id,
            },
          }
        );
        flag.affectedSlots = slotIds;
      }
    }

    await flag.save();

    res.status(201).json({
      message: 'Maintenance flag created successfully',
      maintenance: formatMaintenance(flag),
      blockedSlotsCount: flag.affectedSlots.length,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error creating maintenance flag', error: error.message });
  }
};

// PUT /api/maintenance/:id (Update maintenance flag)
exports.updateMaintenanceFlag = async (req, res) => {
  try {
    const { id } = req.params;
    const flag = await Maintenance.findById(id);

    if (!flag) {
      return res.status(404).json({ message: 'Maintenance flag not found' });
    }

    const prevStatus = flag.status;
    const {
      facilityName,
      facilityType,
      issue,
      priority,
      status,
      scheduledRepairTime,
      notes,
    } = req.body;

    if (facilityName !== undefined) flag.facilityName = facilityName;
    if (facilityType !== undefined) flag.facilityType = facilityType;
    if (issue !== undefined) flag.issue = issue;
    if (priority !== undefined) flag.priority = priority;
    if (status !== undefined) flag.status = status;
    if (scheduledRepairTime !== undefined) flag.scheduledRepairTime = scheduledRepairTime;
    if (notes !== undefined) flag.notes = notes;

    // If transitioned to scheduled/required, auto-block slots
    if (
      (flag.status === 'scheduled' || flag.status === 'required') &&
      (prevStatus === 'available' || prevStatus === 'resolved')
    ) {
      const slotsToBlock = await Slot.find({
        courtName: flag.facilityName,
        status: { $in: ['available', 'pending'] },
      });

      if (slotsToBlock.length > 0) {
        const slotIds = slotsToBlock.map((s) => s._id);
        await Slot.updateMany(
          { _id: { $in: slotIds } },
          {
            $set: {
              status: 'blocked',
              blockedReason: `${flag.facilityName} — Under Maintenance: ${flag.issue}`,
              maintenanceId: flag._id,
            },
          }
        );
        flag.affectedSlots = [...new Set([...flag.affectedSlots, ...slotIds])];
      }
    }

    // If transitioned to available or resolved via update
    if (
      (flag.status === 'available' || flag.status === 'resolved') &&
      prevStatus !== flag.status
    ) {
      flag.resolvedAt = new Date();
      // Unblock slots
      await Slot.updateMany(
        {
          $or: [
            { maintenanceId: flag._id },
            { _id: { $in: flag.affectedSlots } },
          ],
        },
        {
          $set: {
            status: 'available',
            blockedReason: null,
            maintenanceId: null,
          },
        }
      );
      flag.affectedSlots = [];
    }

    await flag.save();

    res.status(200).json({
      message: 'Maintenance flag updated successfully',
      maintenance: formatMaintenance(flag),
    });
  } catch (error) {
    res.status(500).json({ message: 'Error updating maintenance flag', error: error.message });
  }
};

// PATCH or POST /api/maintenance/:id/resolve
// Resolves flag & unblocks all associated slots to make them available to players again
exports.resolveMaintenanceFlag = async (req, res) => {
  try {
    const { id } = req.params;
    const { resolutionNotes } = req.body;

    const flag = await Maintenance.findById(id);
    if (!flag) {
      return res.status(404).json({ message: 'Maintenance flag not found' });
    }

    flag.status = 'available'; // Or resolved / available for play
    flag.resolvedAt = new Date();
    flag.resolutionNotes = resolutionNotes || 'Court verified ready for play';

    // Restore all slots blocked by this maintenance flag
    const unblockedResult = await Slot.updateMany(
      {
        $or: [
          { maintenanceId: flag._id },
          { _id: { $in: flag.affectedSlots } },
        ],
      },
      {
        $set: {
          status: 'available',
          blockedReason: null,
          maintenanceId: null,
        },
      }
    );

    flag.affectedSlots = [];
    await flag.save();

    res.status(200).json({
      message: `Issue resolved! ${flag.facilityName} is now available for booking.`,
      maintenance: formatMaintenance(flag),
      unblockedSlotsCount: unblockedResult.modifiedCount,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error resolving maintenance flag', error: error.message });
  }
};

// DELETE /api/maintenance/:id
exports.deleteMaintenanceFlag = async (req, res) => {
  try {
    const { id } = req.params;
    const flag = await Maintenance.findById(id);

    if (!flag) {
      return res.status(404).json({ message: 'Maintenance flag not found' });
    }

    // Restore any affected slots
    await Slot.updateMany(
      {
        $or: [
          { maintenanceId: flag._id },
          { _id: { $in: flag.affectedSlots } },
        ],
      },
      {
        $set: {
          status: 'available',
          blockedReason: null,
          maintenanceId: null,
        },
      }
    );

    await Maintenance.findByIdAndDelete(id);

    res.status(200).json({
      message: 'Maintenance flag deleted successfully and facility restored',
      deletedFlagId: id,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting maintenance flag', error: error.message });
  }
};
