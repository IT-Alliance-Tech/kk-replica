import mongoose from 'mongoose';
const brandSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true, trim: true },
  slug: { type: String, required: true, unique: true },
  logoUrl: String,
  isActive: { type: Boolean, default: true },
  // Homepage priority fields
  showOnHomepage: { type: Boolean, default: false },
  homepageOrder: { 
    type: Number, 
    min: 1, 
    max: 4
    // Note: sparse behavior handled by partialFilterExpression in schema.index() below
  }
}, { timestamps: true });

// Ensure homepageOrder is unique when showOnHomepage is true
brandSchema.index(
  { homepageOrder: 1 }, 
  { 
    unique: true, 
    partialFilterExpression: { showOnHomepage: true, homepageOrder: { $exists: true } }
  }
);

export default mongoose.model('Brand', brandSchema);
