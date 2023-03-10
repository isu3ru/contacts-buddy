import 'dart:io';

import 'package:contacts_buddy/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditContactPage extends StatefulWidget {
  final Contact contact;

  const EditContactPage({Key? key, required this.contact}) : super(key: key);

  @override
  State<EditContactPage> createState() => _EditContactPageState(this.contact);
}

class _EditContactPageState extends State<EditContactPage> {
  final _formKey = GlobalKey<FormState>();

  final Contact editingContact;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  /// Variables
  XFile? imageFile;

  _EditContactPageState(this.editingContact);

  /// Get from gallery
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // set editing contact image as the initially loaded image file
    if (editingContact.image != null) {
      imageFile = XFile(editingContact.image!);
    }

    // set values to fields
    _nameController.text = editingContact.name!;
    _telephoneController.text = editingContact.telephone!;
    _emailController.text = editingContact.email!;
  }

  /// update the contact entry
  void _handleContactUpdate() async {
    _formKey.currentState!.save();

    if (_formKey.currentState!.validate()) {
      editingContact.name = _nameController.text;
      editingContact.telephone = _telephoneController.text;
      editingContact.email = _emailController.text;

      // save photo
      final imageFile = this.imageFile;
      if (imageFile != null) {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;

        String imagePath = '$appDocPath';
        String savePath = '$imagePath/${imageFile.name}';
        imageFile.saveTo(savePath);
        editingContact.image = savePath;
      }

      editingContact.save();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.done,
              color: Colors.green,
            ),
            title: const Text('Saved'),
            content: const Text('Contact Details Updated Successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  // hide alert dialog
                  Navigator.of(context).pop();

                  // go back to home page
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contact'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      children: [
                        imageFile != null
                            ? CircleAvatar(
                                radius: 64.0,
                                backgroundImage:
                                    FileImage(File(imageFile!.path)),
                              )
                            : const CircleAvatar(
                                radius: 64.0,
                                child: Icon(
                                  Icons.person,
                                  size: 32.0,
                                  color: Colors.white,
                                ),
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: _getFromCamera,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('From Camera'),
                            ),
                            const SizedBox(width: 16.0),
                            TextButton.icon(
                              onPressed: _getFromGallery,
                              icon: const Icon(Icons.image_search),
                              label: const Text('From Gallery'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  key: const Key('name'),
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter name here',
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Name is required.';
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  key: const Key('telphone'),
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter telephone number here',
                    labelText: 'Telephone',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Telephone is required.';
                    }
                    if (value!.length < 10) {
                      return 'Telephone number must contain at least 10 digits.';
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  key: const Key('email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter email address here',
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email address is required.';
                    }
                    final bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value!);
                    if (!emailValid) {
                      return 'Email address is invalid.';
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: 240.0,
                  height: 48.0,
                  child: ElevatedButton.icon(
                    onPressed: _handleContactUpdate,
                    icon: const Icon(Icons.save_as),
                    label: const Text('Update Contact'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
