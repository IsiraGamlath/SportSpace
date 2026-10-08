const Facility = require('../models/Facility');
const Slot = require('../models/Slot');

// Initial default facilities to seed if none exist
const DEFAULT_FACILITIES = [
  {
    name: 'Badminton Court 1',
    type: 'Badminton',
    description: 'BWF-standard indoor synthetic mat court with LED lighting.',
    hourlyRate: 2500,
    openingTime: '06:00 AM',
    closingTime: '10:00 PM',
    status: 'active',
    capacity: 4,
    surface: 'Synthetic Mat',
    isIndoor: true,
  },
  {
    name: 'Badminton Court 2',
    type: 'Badminton',
    description: 'Indoor wooden parquet court suited for training and matches.',
    hourlyRate: 2500,
    openingTime: '06:00 AM',
    closingTime: '10:00 PM',
    status: 'active',
    capacity: 4,
    surface: 'Wooden Parquet',
    isIndoor: true,
  },
  {
    name: 'Tennis Court 1',
    type: 'Tennis',
    description: 'Outdoor acrylic hard court with professional floodlights.',
    hourlyRate: 3500,
    openingTime: '06:00 AM',
    closingTime: '09:00 PM',
    status: 'active',
    capacity: 4,
    surface: 'Hard Court (Acrylic)',
    isIndoor: false,
  },
  {
    name: 'Basketball Court',
    type: 'Basketball',
    description: 'Full-court indoor FIBA standard basketball arena.',
    hourlyRate: 3000,
    openingTime: '07:00 AM',
    closingTime: '10:00 PM',
    status: 'active',
    capacity: 10,
    surface: 'Hardwood Maple',
    isIndoor: true,
  },
  {
    name: 'Futsal Pitch',
    type: 'Futsal',
    description: 'Enclosed artificial turf 5-a-side football arena.',
    hourlyRate: 4000,
    openingTime: '07:00 AM',
    closingTime: '11:00 PM',
    status: 'active',
    capacity: 10,
    surface: 'Artificial Turf',
    isIndoor: true,
  },
];

// Helper to format facility output
const formatFacility = (f) => {
  const obj = f.toObject ? f.toObject() : { ...f };
  obj.id = obj._id ? obj._id.toString() : obj.id;
  return obj;
};

// Seed default facilities on startup if collection is empty
exports.seedFacilities = async () => {
  try {
    const count = await Facility.countDocuments();
    if (count === 0) {
      await Facility.insertMany(DEFAULT_FACILITIES);
      console.log('Seeded default sports facilities');
    }
  } catch (err) {
    console.error('Error seeding facilities:', err.message);
  }
};

// GET /api/facilities
// Supports query: type, status, search
exports.getFacilities = async (req, res) => {
  try {
    const { type, status, search } = req.query;
    const query = {};

    if (type && type !== 'All') {
      query.type = type;
    }

    if (status && status !== 'All') {
      query.status = status;
    }

    if (search && search.trim()) {
      query.name = { $regex: search.trim(), $options: 'i' };
    }

    const facilities = await Facility.find(query).sort({ createdAt: -1 });
    res.status(200).json(facilities.map(formatFacility));
  } catch (error) {
    res.status(500).json({
      message: 'Failed to fetch facilities',
      error: error.message,
    });
  }
};

// GET /api/facilities/:id
exports.getFacilityById = async (req, res) => {
  try {
    const { id } = req.params;
    const facility = await Facility.findById(id);

    if (!facility) {
      return res.status(404).json({ message: 'Facility not found' });
    }

    res.status(200).json(formatFacility(facility));
  } catch (error) {
    res.status(500).json({
      message: 'Failed to fetch facility',
      error: error.message,
    });
  }
};

// POST /api/facilities (Create new facility)
exports.createFacility = async (req, res) => {
  try {
    const {
      name,
      type,
      description,
      hourlyRate,
      openingTime,
      closingTime,
      status,
      capacity,
      surface,
      isIndoor,
      centreName,
    } = req.body;

    if (!name || !name.trim()) {
      return res.status(400).json({ message: 'Facility name is required' });
    }

    if (!type || !type.trim()) {
      return res.status(400).json({ message: 'Facility type is required' });
    }

    // Check for existing facility with same name
    const existing = await Facility.findOne({
      name: { $regex: `^${name.trim()}$`, $options: 'i' },
    });

    if (existing) {
      return res.status(409).json({
        message: `A facility named "${name.trim()}" already exists`,
      });
    }

    const newFacility = await Facility.create({
      name: name.trim(),
      type: type.trim(),
      description: description || '',
      hourlyRate: Number(hourlyRate) || 2500,
      openingTime: openingTime || '06:00 AM',
      closingTime: closingTime || '10:00 PM',
      status: status || 'active',
      capacity: Number(capacity) || 4,
      surface: surface || 'Synthetic',
      isIndoor: isIndoor !== undefined ? isIndoor : true,
      centreName: centreName || 'Colombo Sports Centre',
    });

    res.status(201).json({
      message: 'Facility created successfully',
      facility: formatFacility(newFacility),
    });
  } catch (error) {
    res.status(500).json({
      message: 'Failed to create facility',
      error: error.message,
    });
  }
};

// PUT /api/facilities/:id (Update facility)
exports.updateFacility = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      type,
      description,
      hourlyRate,
      openingTime,
      closingTime,
      status,
      capacity,
      surface,
      isIndoor,
      centreName,
    } = req.body;

    const facility = await Facility.findById(id);
    if (!facility) {
      return res.status(404).json({ message: 'Facility not found' });
    }

    const oldName = facility.name;

    // Check duplicate name if name changed
    if (name && name.trim().toLowerCase() !== oldName.toLowerCase()) {
      const duplicate = await Facility.findOne({
        _id: { $ne: id },
        name: { $regex: `^${name.trim()}$`, $options: 'i' },
      });
      if (duplicate) {
        return res.status(409).json({
          message: `Another facility named "${name.trim()}" already exists`,
        });
      }
      facility.name = name.trim();
    }

    if (type !== undefined) facility.type = type.trim();
    if (description !== undefined) facility.description = description;
    if (hourlyRate !== undefined) facility.hourlyRate = Number(hourlyRate) || facility.hourlyRate;
    if (openingTime !== undefined) facility.openingTime = openingTime;
    if (closingTime !== undefined) facility.closingTime = closingTime;
    if (status !== undefined) facility.status = status;
    if (capacity !== undefined) facility.capacity = Number(capacity) || facility.capacity;
    if (surface !== undefined) facility.surface = surface;
    if (isIndoor !== undefined) facility.isIndoor = isIndoor;
    if (centreName !== undefined) facility.centreName = centreName;

    await facility.save();

    // If name changed, optionally update existing unbooked slots
    if (name && name.trim() !== oldName) {
      Slot.updateMany(
        { courtName: oldName, status: 'available' },
        { $set: { courtName: name.trim(), facilityType: facility.type } }
      ).catch(() => {});
    }

    res.status(200).json({
      message: 'Facility updated successfully',
      facility: formatFacility(facility),
    });
  } catch (error) {
    res.status(500).json({
      message: 'Failed to update facility',
      error: error.message,
    });
  }
};

// DELETE /api/facilities/:id (Delete facility)
exports.deleteFacility = async (req, res) => {
  try {
    const { id } = req.params;
    const facility = await Facility.findById(id);

    if (!facility) {
      return res.status(404).json({ message: 'Facility not found' });
    }

    // Check if facility has active/booked slots
    const bookedSlotsCount = await Slot.countDocuments({
      courtName: facility.name,
      status: 'booked',
    });

    if (bookedSlotsCount > 0) {
      return res.status(400).json({
        message: `Cannot delete "${facility.name}" because it has ${bookedSlotsCount} active booking(s). You can set its status to "inactive" instead.`,
      });
    }

    // Remove available unbooked slots for this facility
    await Slot.deleteMany({ courtName: facility.name, status: 'available' });

    await Facility.findByIdAndDelete(id);

    res.status(200).json({
      message: `Facility "${facility.name}" deleted successfully`,
    });
  } catch (error) {
    res.status(500).json({
      message: 'Failed to delete facility',
      error: error.message,
    });
  }
};
