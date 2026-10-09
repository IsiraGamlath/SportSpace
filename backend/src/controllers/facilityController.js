const Facility = require('../models/Facility');
const Slot = require('../models/Slot');
const { dispatchNotification } = require('./notificationsController');
const cloudinary = require('cloudinary').v2;

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Initial default facilities with rich data and photos
const DEFAULT_FACILITIES = [
  {
    name: 'Badminton Court 1',
    type: 'Badminton',
    location: 'Colombo 07, Reid Avenue (Main Sports Arena)',
    description: 'BWF-standard indoor synthetic mat court with tournament-grade LED lighting and spectator seating.',
    openTime: '06:00 AM – 10:00 PM',
    openingTime: '06:00 AM',
    closingTime: '10:00 PM',
    availableSports: ['Badminton'],
    amenities: ['Free Parking', 'Changing Rooms', 'Hot Showers', 'Secure Lockers', 'LED Lighting', 'Pro Shop Equipment Rental'],
    accessibility: ['Wheelchair Accessible Entrance', 'Ground Floor Access', 'Accessible Restroom'],
    contactNumber: '+94 11 269 1111',
    photoUrl: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=1000&q=80',
    photos: [
      'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1613918431703-aa632128a31e?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1521537634581-0dced2fee2ef?auto=format&fit=crop&w=1000&q=80',
    ],
    hourlyRate: 2500,
    status: 'active',
    capacity: 4,
    surface: 'Synthetic Mat',
    isIndoor: true,
  },
  {
    name: 'Badminton Court 2',
    type: 'Badminton',
    location: 'Colombo 07, Reid Avenue (Hall B)',
    description: 'Indoor wooden parquet court designed for fast rallies, regular training sessions, and club tournaments.',
    openTime: '06:00 AM – 10:00 PM',
    openingTime: '06:00 AM',
    closingTime: '10:00 PM',
    availableSports: ['Badminton', 'Table Tennis'],
    amenities: ['Free Parking', 'Changing Rooms', 'Showers', 'Lockers', 'Spectator Gallery'],
    accessibility: ['Ground Floor Access', 'Accessible Ramp'],
    contactNumber: '+94 11 269 1112',
    photoUrl: 'https://images.unsplash.com/photo-1613918431703-aa632128a31e?auto=format&fit=crop&w=1000&q=80',
    photos: [
      'https://images.unsplash.com/photo-1613918431703-aa632128a31e?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=1000&q=80',
    ],
    hourlyRate: 2500,
    status: 'active',
    capacity: 4,
    surface: 'Wooden Parquet',
    isIndoor: true,
  },
  {
    name: 'Tennis Court 1',
    type: 'Tennis',
    location: 'Colombo 07, Reid Avenue (Outdoor Arena)',
    description: 'Championship-grade acrylic hard court equipped with high-intensity night floodlights and ball boy shelters.',
    openTime: '06:00 AM – 09:00 PM',
    openingTime: '06:00 AM',
    closingTime: '09:00 PM',
    availableSports: ['Tennis'],
    amenities: ['Floodlights (Night Play)', 'Racket Stringing Service', 'Parking', 'Clubhouse Cafe', 'Changing Rooms'],
    accessibility: ['Wheelchair Accessible Pathways', 'Step-free Court Access'],
    contactNumber: '+94 11 269 1113',
    photoUrl: 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=1000&q=80',
    photos: [
      'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1531315630201-bb15abeb1653?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=1000&q=80',
    ],
    hourlyRate: 3500,
    status: 'active',
    capacity: 4,
    surface: 'Hard Court (Acrylic)',
    isIndoor: false,
  },
  {
    name: 'Basketball Court',
    type: 'Basketball',
    location: 'Colombo 07, Reid Avenue (Indoor Stadium)',
    description: 'Full-court indoor FIBA standard basketball arena with electronic scoreboard, glass backboards, and maple flooring.',
    openTime: '07:00 AM – 10:00 PM',
    openingTime: '07:00 AM',
    closingTime: '10:00 PM',
    availableSports: ['Basketball', 'Volleyball'],
    amenities: ['Electronic Scoreboard', 'Spectator Bleachers (150 seats)', 'Lockers', 'Water Dispenser', 'First Aid Station'],
    accessibility: ['Elevator Access', 'Wheelchair Seating Zone', 'Accessible Restrooms'],
    contactNumber: '+94 11 269 1114',
    photoUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=1000&q=80',
    photos: [
      'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1519861531473-9200262188bf?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1000&q=80',
    ],
    hourlyRate: 3000,
    status: 'active',
    capacity: 10,
    surface: 'Hardwood Maple',
    isIndoor: true,
  },
  {
    name: 'Futsal Pitch',
    type: 'Futsal',
    location: 'Colombo 07, Reid Avenue (Pitch 1)',
    description: 'Enclosed 5-a-side artificial turf arena with shock-absorbing underlay, rebound boards, and overhead netting.',
    openTime: '07:00 AM – 11:00 PM',
    openingTime: '07:00 AM',
    closingTime: '11:00 PM',
    availableSports: ['Futsal', 'Football'],
    amenities: ['Night Floodlighting', 'Match Balls & Bibs Included', 'Showers', 'Locker Rooms', 'Refreshment Kiosk'],
    accessibility: ['Ramp Access to Pitch', 'Accessible Parking Space'],
    contactNumber: '+94 11 269 1115',
    photoUrl: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&w=1000&q=80',
    photos: [
      'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=1000&q=80',
    ],
    hourlyRate: 4000,
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
  if (!obj.photoUrl && obj.photos && obj.photos.length > 0) {
    obj.photoUrl = obj.photos[0];
  }
  if (!obj.openTime && (obj.openingTime || obj.closingTime)) {
    obj.openTime = `${obj.openingTime || '06:00 AM'} – ${obj.closingTime || '10:00 PM'}`;
  }
  return obj;
};

// Seed default facilities on startup or backfill missing fields
exports.seedFacilities = async () => {
  try {
    const count = await Facility.countDocuments();
    if (count === 0) {
      await Facility.insertMany(DEFAULT_FACILITIES);
      console.log('Seeded default sports facilities with photos and details');
    } else {
      // Backfill missing photos/details for existing facilities
      for (const def of DEFAULT_FACILITIES) {
        const existing = await Facility.findOne({ name: def.name });
        if (existing) {
          let updated = false;
          if (!existing.photos || existing.photos.length < 3) {
            existing.photos = def.photos;
            existing.photoUrl = def.photoUrl;
            updated = true;
          }
          if (!existing.location || existing.location.trim() === '') {
            existing.location = def.location;
            updated = true;
          }
          if (!existing.availableSports || existing.availableSports.length === 0) {
            existing.availableSports = def.availableSports;
            updated = true;
          }
          if (!existing.amenities || existing.amenities.length === 0) {
            existing.amenities = def.amenities;
            updated = true;
          }
          if (!existing.accessibility || existing.accessibility.length === 0) {
            existing.accessibility = def.accessibility;
            updated = true;
          }
          if (!existing.contactNumber || existing.contactNumber.trim() === '') {
            existing.contactNumber = def.contactNumber;
            updated = true;
          }
          if (!existing.openTime || existing.openTime.trim() === '') {
            existing.openTime = def.openTime;
            updated = true;
          }
          if (updated) {
            await existing.save();
          }
        }
      }
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
      query.$or = [{ type: type }, { availableSports: type }];
    }

    if (status && status !== 'All') {
      query.status = status;
    }

    if (search && search.trim()) {
      query.$or = [
        { name: { $regex: search.trim(), $options: 'i' } },
        { location: { $regex: search.trim(), $options: 'i' } },
        { type: { $regex: search.trim(), $options: 'i' } },
      ];
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

// POST /api/facilities/upload-photo (Upload facility photo to Cloudinary)
exports.uploadPhoto = async (req, res) => {
  try {
    let fileToUpload = null;

    if (req.file) {
      // If multer already uploaded to Cloudinary
      if (req.file.path) {
        return res.status(200).json({
          url: req.file.path,
          message: 'Photo uploaded successfully',
        });
      }
      // If in buffer
      if (req.file.buffer) {
        fileToUpload = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
      }
    } else if (req.body && req.body.photoData) {
      fileToUpload = req.body.photoData;
    }

    if (!fileToUpload) {
      return res.status(400).json({ message: 'No photo provided for upload' });
    }

    const result = await cloudinary.uploader.upload(fileToUpload, {
      folder: 'sportspace_facilities',
      allowed_formats: ['jpg', 'png', 'jpeg', 'webp'],
    });

    res.status(200).json({
      url: result.secure_url,
      message: 'Photo uploaded successfully',
    });
  } catch (error) {
    console.error('Error uploading facility photo:', error);
    res.status(500).json({
      message: 'Photo upload failed',
      error: error.message,
    });
  }
};

// POST /api/facilities (Create new facility)
exports.createFacility = async (req, res) => {
  try {
    const {
      name,
      location,
      description,
      openTime,
      openingTime,
      closingTime,
      availableSports,
      amenities,
      accessibility,
      contactNumber,
      photos,
      photoUrl,
      hourlyRate,
      type,
      status,
      capacity,
      surface,
      isIndoor,
      centreName,
    } = req.body;

    if (!name || !name.trim()) {
      return res.status(400).json({ message: 'Facility name is required' });
    }

    const trimmedName = name.trim();

    // Check for existing facility with same name
    const existing = await Facility.findOne({
      name: { $regex: `^${trimmedName}$`, $options: 'i' },
    });

    if (existing) {
      return res.status(409).json({
        message: `A facility named "${trimmedName}" already exists`,
      });
    }

    const sportsList = Array.isArray(availableSports)
      ? availableSports
      : typeof availableSports === 'string' && availableSports.trim()
      ? availableSports.split(',').map((s) => s.trim()).filter(Boolean)
      : [type || 'Badminton'];

    const amenitiesList = Array.isArray(amenities)
      ? amenities
      : typeof amenities === 'string' && amenities.trim()
      ? amenities.split(',').map((s) => s.trim()).filter(Boolean)
      : ['Parking', 'Changing Rooms', 'Showers'];

    const accessibilityList = Array.isArray(accessibility)
      ? accessibility
      : typeof accessibility === 'string' && accessibility.trim()
      ? accessibility.split(',').map((s) => s.trim()).filter(Boolean)
      : ['Wheelchair Accessible'];

    const photosList = Array.isArray(photos)
      ? photos
      : photoUrl
      ? [photoUrl]
      : [];

    const primaryPhoto = photoUrl || (photosList.length > 0 ? photosList[0] : '');

    const resolvedOpenTime =
      openTime || `${openingTime || '06:00 AM'} – ${closingTime || '10:00 PM'}`;

    const newFacility = await Facility.create({
      name: trimmedName,
      location: location ? location.trim() : 'Colombo 07, Reid Avenue',
      description: description || '',
      openTime: resolvedOpenTime,
      openingTime: openingTime || '06:00 AM',
      closingTime: closingTime || '10:00 PM',
      availableSports: sportsList,
      amenities: amenitiesList,
      accessibility: accessibilityList,
      contactNumber: contactNumber ? contactNumber.trim() : '+94 11 269 1111',
      photos: photosList,
      photoUrl: primaryPhoto,
      hourlyRate: Number(hourlyRate) || 2500,
      type: type || (sportsList.length > 0 ? sportsList[0] : 'Badminton'),
      status: status || 'active',
      capacity: Number(capacity) || 4,
      surface: surface || 'Synthetic',
      isIndoor: isIndoor !== undefined ? isIndoor : true,
      centreName: centreName || 'Colombo Sports Centre',
    });

    const formatted = formatFacility(newFacility);

    // Requirement 6: when facility manager adds a facility, notify player and community member
    await dispatchNotification({
      targetRoles: ['player', 'communityMember'],
      category: 'facility',
      title: 'New Facility Added',
      message: `Facility "${newFacility.name}" is now available for booking and events.`,
      accentColor: 'green',
      metadata: { facilityId: formatted.id, action: 'create' },
    });

    res.status(201).json({
      message: 'Facility created successfully',
      facility: formatted,
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
      location,
      description,
      openTime,
      openingTime,
      closingTime,
      availableSports,
      amenities,
      accessibility,
      contactNumber,
      photos,
      photoUrl,
      hourlyRate,
      type,
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

    if (location !== undefined) facility.location = location.trim();
    if (description !== undefined) facility.description = description;
    if (openTime !== undefined) facility.openTime = openTime;
    if (openingTime !== undefined) facility.openingTime = openingTime;
    if (closingTime !== undefined) facility.closingTime = closingTime;
    if (contactNumber !== undefined) facility.contactNumber = contactNumber.trim();
    if (photoUrl !== undefined) facility.photoUrl = photoUrl;
    if (photos !== undefined) {
      facility.photos = Array.isArray(photos) ? photos : [photos];
      if (!facility.photoUrl && facility.photos.length > 0) {
        facility.photoUrl = facility.photos[0];
      }
    }
    if (availableSports !== undefined) {
      facility.availableSports = Array.isArray(availableSports)
        ? availableSports
        : availableSports.split(',').map((s) => s.trim()).filter(Boolean);
    }
    if (amenities !== undefined) {
      facility.amenities = Array.isArray(amenities)
        ? amenities
        : amenities.split(',').map((s) => s.trim()).filter(Boolean);
    }
    if (accessibility !== undefined) {
      facility.accessibility = Array.isArray(accessibility)
        ? accessibility
        : accessibility.split(',').map((s) => s.trim()).filter(Boolean);
    }

    if (type !== undefined) facility.type = type.trim();
    if (hourlyRate !== undefined) facility.hourlyRate = Number(hourlyRate) || facility.hourlyRate;
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

    const formatted = formatFacility(facility);

    // Requirement 7: when facility manager edits facility info, notify player, community member, and facility manager
    await dispatchNotification({
      targetRoles: ['player', 'communityMember', 'facilityManager'],
      category: 'facility',
      title: 'Facility Update',
      message: `Facility details have been updated for "${facility.name}".`,
      accentColor: 'orange',
      metadata: { facilityId: formatted.id, action: 'edit' },
    });

    res.status(200).json({
      message: 'Facility updated successfully',
      facility: formatted,
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

    // Requirement 6: when facility manager removes a facility, notify player and community member
    await dispatchNotification({
      targetRoles: ['player', 'communityMember'],
      category: 'facility',
      title: 'Facility Removed',
      message: `Facility "${facility.name}" has been removed from active service.`,
      accentColor: 'red',
      metadata: { facilityId: id, action: 'delete' },
    });

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
