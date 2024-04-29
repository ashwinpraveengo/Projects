//@desc Get All contacts
//@route GET /api/contacts
//@access public
const asyncHandler=require("express-async-handler")

const getContacts = asyncHandler(async (req,res) => {
    res.status(200).json({message:"Get all contacts"});
});

//@desc Create new contacts
//@route POST /api/contacts
//@access public

const createContact = async (req,res) => {
    console.log("The request body is :",req.body);
    const {name,email,phone}=req.body;
    if (!name || !email || !phone ){
        res.status(400);
        throw new Error("All fields are mandatory");
    }
    res.status(201).json({message:"Create Contact"});
    
}


//@desc Get Contact
//@route GET /api/contacts/:id
//@access public

const getContact = async (req,res) => {
    res.status(200).json({message:`Get Contact for ${req.params.id}`});
}


//@desc Update contact
//@route PUT /api/contacts/
//@access public

const updateContact =  async (req,res) => {
    res.status(200).json({message:`Update contact for ${req.params.id}`});
}

//@desc delete contacts
//@route POST /api/contacts

//@access public

const deleteContact = async (req,res) => {
    res.status(200).json({message:`Delete contact for ${req.params.id}`});
}
 
//@desc Create new contacts
//@route POST /api/contacts
//@access public


module.exports = { getContact,createContact,getContacts,updateContact,deleteContact};