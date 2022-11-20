//Document
//-user id
//- created at
//- title
// contents

const mongoose = require('mongoose');

const documentSchema = mongoose.Schema({
    uid: {
        required: true,
        type: String,
    },
    createdAt: {
        required:true,
        type: Number,
    },
    title: {
        required: true,
        type: String,
        trim: true,
    },
    contents: {
        required: false,
        type: Array,
        default: [],
    },
    pinned: {
        required: false,
        type: Boolean,
        default: false
    },
    favorite: {
        required:false,
        type: Boolean,
        default: false
    }
});

const Document = mongoose.model('Document', documentSchema);

module.exports = Document;