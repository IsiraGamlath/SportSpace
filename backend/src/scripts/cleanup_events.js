const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../../.env') });

async function cleanup() {
  await mongoose.connect(process.env.MONGODB_URI);
  const Event = require('../models/Event');
  const res = await Event.deleteMany({
    description: { $regex: 'Booking Ref', $options: 'i' },
  });
  console.log('Deleted booking ref events:', res.deletedCount);

  const remaining = await Event.find({}, 'title eventType facility date time');
  console.log(`Remaining events (${remaining.length}):`);
  remaining.forEach((e) => {
    console.log(` - ${e.title} [${e.eventType}] at ${e.facility}`);
  });
  await mongoose.disconnect();
}

cleanup().catch((err) => {
  console.error(err);
  process.exit(1);
});
