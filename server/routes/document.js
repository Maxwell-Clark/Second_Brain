const express = require('express');
const Document = require('../models/document');
const auth = require("../middleware/auth");
const documentRouter = express.Router();

documentRouter.post('/doc/create', auth, async (req, res)=> {
    try{
        const { createdAt } = req.body;
        let document = new Document({
            uid: req.user,
            title: 'Untitled Document',
            createdAt,
        });
        document = await document.save();
        res.json(document);
    } catch (e) {
        res.status(500).json({error:e.message})
    }
})

documentRouter.get('/doc/me', auth, async (req, res) => {
    try{
        let documents = await Document.find({uid: req.user});
        res.json(documents);
    } catch (e) {
        res.status(500).json({ error: e.message});
    }
})

documentRouter.post('/doc/title', auth, async (req, res)=> {
    try{
        const { id, title } = req.body;
        const document = await Document.findByIdAndUpdate(id, {title});
        res.json(document);
    } catch (e) {
        res.status(500).json({error:e.message})
    }
})

documentRouter.put('/doc/:id/pinned', auth, async (req, res) => {
    try {
        const pinned = req.body.pinned;
        const doc = await Document.findByIdAndUpdate(req.params.id, {pinned});
        res.json(doc);
    } catch (e) {
        res.status(500).json({error:e.message})
    }
})

documentRouter.put('/doc/:id/favorite', auth, async (req, res) => {
    try {
        const favorite = req.body.favorite;
        const doc = await Document.findByIdAndUpdate(req.params.id, {favorite});
        res.json(doc);
    } catch (e) {
        res.status(500).json({error:e.message})
    }
})

documentRouter.get('/doc/:id', auth, async (req, res) => {
    try{
        const document = await Document.findById(req.params.id);
        res.json(document);
    } catch (e) {
        res.status(500).json({ error: e.message});
    }
})

documentRouter.delete('/doc/:id', auth, async (req, res) => {
    try{
        const document = await Document.findById(req.params.id);
        await document.deleteOne();

        res.send("Document \"" + document.title + "\" was Deleted Successfully");
    } catch (e) {
        res.status(500).json({ error: e.message});
    }
})

module.exports = documentRouter;