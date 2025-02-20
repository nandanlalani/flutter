import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../string_const.dart';
import '../backend/Database.dart';

class AddProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final int? userId;

  AddProfileScreen({this.userData, this.userId});

  @override
  _AddProfileScreenState createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _conPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  bool isHide1 = true;
  bool isHide2 = true;

  String? _selectedCity;
  String? _selectedGender;
  List<String> _selectedHobbies = [];
  List<String> _selectedUsername = [];

  final List<String> _hobbies = ['Reading', 'Traveling', 'Music', 'Sports', 'Dancing', 'Cooking'];
  final List<String> _cities = ['Ahmedabad', 'Anand', 'Jamnagar', 'Rajkot', 'Surat'];

  final MyDatabase _database = MyDatabase.instance;

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _mobileError;
  String? _dobError;
  String? _passwordError;
  String? _conPasswordError;
  String? _userNameError;

  final List<DateFormat> _dateFormats = [
    DateFormat('yyyy/MM/dd'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('MM/dd/yyyy'),
  ];

  DateTime? _parseDateString(String dateStr) {
    for (var format in _dateFormats) {
      try {
        return format.parse(dateStr);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  InputDecoration _inputDecoration(String label, IconData icon, String? errorText) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      errorText: errorText,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _firstNameController.text = widget.userData!["user_firstName"] ?? '';
      _lastNameController.text = widget.userData!["user_lastName"] ?? '';
      _emailController.text = widget.userData!["user_email"] ?? '';
      _mobileController.text = widget.userData!["user_number"] ?? '';
      _dobController.text = widget.userData!["dob"] ?? '';
      _selectedCity = widget.userData!["city"];
      _selectedGender = widget.userData!["gender"];
      _passwordController.text = widget.userData!["password"];
      _userNameController.text = widget.userData!["user_Name"];
      _fetchUserHobbies(widget.userId!);
    }
    _fetchUsername(); // Fetch usernames for validation
  }

  Future<void> _fetchUsername() async {
    List<Map<String, dynamic>> userNames = await _database.getAllUsername();
    setState(() {
      _selectedUsername = userNames.map((user) => user["user_Name"].toString()).toList();
    });
  }

  Future<void> _fetchUserHobbies(int userId) async {
    List<Map<String, dynamic>> hobbies = await _database.getHobbiesByUser(userId);
    setState(() {
      _selectedHobbies = hobbies.map((hobby) => hobby["hobby"] as String).toList();
    });
  }

  // ✅ Added Missing Validation Methods

  void _validateFirstName(String value) {
    setState(() {
        _firstNameError = RegExp(r"^[a-zA-Z]{3,50}$").hasMatch(value) ? null : "must contain alphabets only and 3-50 characters";
    });
  }

  void _validateLastName(String value) {
    setState(() {
      _lastNameError = RegExp(r"^[a-zA-Z]{3,50}$").hasMatch(value) ? null : "must contain alphabets only and 3-50 characters";
    });
  }

  void _validateEmail(String value) {
    setState(() {
      _emailError = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)
          ? null
          : "Enter a valid email address";
    });
  }

  void _validateUserName(String value) async {
    // Local validation for format
    if (!RegExp(r"^[a-zA-Z0-9]{3,50}$").hasMatch(value)) {
      setState(() {
        _userNameError = "Username must contain alphabets and digits only (3-50 characters)";
      });
      return; // Stop further checks
    }

    // Get old username (if editing an existing profile)
    String? oldUsername = widget.userData?["user_Name"];

    // If the username is the same as the old one, no need to check for duplicates
    if (oldUsername != null && value == oldUsername) {
      setState(() {
        _userNameError = null;
      });
      return;
    }

    // Fetch usernames from the database
    List<Map<String, dynamic>> userNames = await _database.getAllUsername();
    List<String> existingUsernames = userNames.map((user) => user["user_Name"].toString()).toList();

    // Check if username exists in the database (except for the old username)
    if (existingUsernames.contains(value)) {
      setState(() {
        _userNameError = "Username is already taken";
      });
    } else {
      setState(() {
        _userNameError = null;
      });
    }
  }




  void _validateMobile(String value) {
    setState(() {
      _mobileError = RegExp(r"^\d{10}$").hasMatch(value) ? null : "Enter a valid 10-digit mobile number";
    });
  }

  void _validatePassword(String value){
    setState(() {
      _passwordError = "";
      if(value == null){
        _passwordError = "Please enter password";
      }
      else if(!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^A-Za-z0-9]).{6,}$').hasMatch(value)){
        _passwordError = "Must contain atleast one Uppercase,Lowercase,special character,digit and min 6 characters";
      }
      // else if(!RegExp(r'[a-z]').hasMatch(value)){
      //   _passwordError = "Lowercase letter is missing";
      // }
      // else if (!RegExp(r'[0-9]').hasMatch(value)) {
      //   _passwordError = 'Digit is missing.';
      // }
      // else if(!RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)){
      //   _passwordError = "Special character is missing.";
      // }
      else {
        _passwordError = null;
      }
    });
  }

  void _validateconPassword(String value){
    setState(() {
      _conPasswordError = "";
      if(value == null){
        _conPasswordError = "Please enter password";
      }
      else if(!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^A-Za-z0-9]).{6,}$').hasMatch(value)){
        _conPasswordError = "Must contain atleast one Uppercase,Lowercase,special character,digit and min 6 characters";
      }
      // else if(!RegExp(r'[a-z]').hasMatch(value)){
      //   _conPasswordError = "Lowercase letter is missing";
      // }
      // else if (!RegExp(r'[0-9]').hasMatch(value)) {
      //   _conPasswordError = 'Digit is missing.';
      // }
      // else if(!RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)){
      //   _conPasswordError = "Special character is missing.";
      // }
      else if(value.toString() != _passwordController.text){
        _conPasswordError = "Password and Confirm Password Does Not Match";
        _passwordError = "Password and Confirm Password Does Not Match";
      }
      else {
        _conPasswordError = null;
        _passwordError = null;
      }
    });
  }


  void _validateDOB() {
    setState(() {
      if (_dobController.text.isNotEmpty) {
        DateTime? dob = _parseDateString(_dobController.text);

        if (dob != null) {
          DateTime now = DateTime.now();
          int age = now.year - dob.year;
          if (dob.month > now.month || (dob.month == now.month && dob.day > now.day)) {
            age--;
          }
          _dobError = (age >= 18 && age <= 80)
              ? null
              : "You must be at least 18 years old to register";

          // Update the date format to be consistent
          _dobController.text = DateFormat('dd/MM/yyyy').format(dob);
        } else {
          _dobError = "Invalid date format";
        }
      } else {
        _dobError = "Date of Birth is required";
      }
    });
  }

  void _resetForm(){
    _firstNameController.text = "";
    _lastNameController.text = "";
    _userNameController.text = "";
    _emailController.text = "";
    _passwordController.text = "";
    _conPasswordController.text = "";
    _mobileController.text = "";
    _dobController.text = "";
    _selectedCity = null;
    _selectedGender = null;
    _selectedHobbies = [];
    setState(() {

    });
  }

  Future<void> _submitForm() async {

    _validateFirstName(_firstNameController.text);
    _validateLastName(_lastNameController.text);
    _validateEmail(_emailController.text);
    _validateMobile(_mobileController.text);
    _validateUserName(_userNameController.text);
    _validatePassword(_passwordController.text);
    _validateconPassword(_conPasswordController.text);

    print("Validation errors: $_firstNameError, $_lastNameError, $_emailError, $_mobileError, $_passwordError, $_conPasswordError");
    if(_conPasswordController.text != _passwordController.text){
      _conPasswordError = "Password and Confirm Password Does Not Match";
      _passwordError = "Password and Confirm Password Does Not Match";
    }

    if (_firstNameError == null &&
        _lastNameError == null &&
        _userNameError == null &&
        _emailError == null &&
        _mobileError == null &&
        _passwordError == null &&
        _conPasswordError == null) {
      if (_selectedCity == null) {
        _showAlert("Please select a city");
        return;
      }

      if (_selectedGender == null) {
        _showAlert("Please select a gender");
        return;
      }

      if (_selectedHobbies.isEmpty) {
        _showAlert("Please select at least one hobby");
        return;
      }

      print("Validation passed. Saving to database...");

      Map<String, dynamic> user = {
        FNAME: _firstNameController.text,
        LNAME: _lastNameController.text,
        EMAIL: _emailController.text,
        NUMBER: _mobileController.text,
        "dob": _dobController.text,
        CITY: _selectedCity!,
        GENDER: _selectedGender!,
        PASSWORD: _passwordController.text,
        "user_Name": _userNameController.text,
      };

      if (widget.userId != null) {
        await _database.updateUser(widget.userId!, user);
      } else {
        int userId = await _database.insertUser(user);
        for (String hobby in _selectedHobbies) {
          await _database.insertHobby({"user_id": userId, "hobby": hobby});
        }
      }

      print("User saved successfully!");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.userId != null ? 'User updated successfully!' : 'User added successfully!')),
      );

      Navigator.pop(context, true);
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Validation Error"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.userId != null ? 'Edit Profile' : 'Register',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30,),
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey,),
                      shape: BoxShape.circle,

                    ),
                    child: Icon(Icons.person,size: 150,),
                  ),
                ),
                Text("First Name: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _firstNameController,
                  decoration: _inputDecoration("FirstName", Icons.person , _firstNameError),
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                  ],
                  onChanged: _validateFirstName,

                ),
                SizedBox(height: 10),
                Text("Last Name: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _lastNameController,
                  decoration: _inputDecoration("LastName", Icons.person , _lastNameError),
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                  ],
                  onChanged: _validateLastName,

                ),
                SizedBox(height: 10),
                Text("User Name: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _userNameController,
                  decoration: _inputDecoration("Username", Icons.verified_user_rounded , _userNameError),
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9@_\s]")),
                  ],
                  onChanged: _validateUserName,

                ),
                SizedBox(height: 10),
                Text("Email Address: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email", Icons.email , _emailError),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _validateEmail,

                ),
                SizedBox(height: 10),
                Text("Password: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _passwordController,
                  obscureText: isHide1,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      label: Text("Password"),
                      prefixIcon: Icon(Icons.password),
                      suffixIcon: IconButton(icon: Icon(
                          isHide1 ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            if(widget.userData!["user_id"] == null)
                              isHide1 = !isHide1;
                            else{
                              _showAlert("Cannot see password, enter confirm password to update details");
                            }
                          });

                        },),
                    errorText: _passwordError,

                  ),
                  onChanged: _validatePassword,
                ),
                SizedBox(height: 10,),
                Text("Confirm Password: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _conPasswordController,
                  obscureText: isHide2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    label: Text("Confirm Password"),
                    prefixIcon: Icon(Icons.password),
                    suffixIcon: IconButton(icon: Icon(
                        isHide2 ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          isHide2 = !isHide2;
                        });
                      },),
                    errorText: _conPasswordError,

                  ),
                  onChanged: _validateconPassword,
                ),
                SizedBox(height: 10),
                Text("Mobile Number: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _mobileController,
                  decoration: _inputDecoration("Mobile Number", Icons.phone , _mobileError),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 10,
                  onChanged: _validateMobile,
                ),
                SizedBox(height: 10),
                Text("Date of Birth: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _dobController,
                  decoration: _inputDecoration('Date of Birth', Icons.calendar_today, _dobError),
                  readOnly: true,
                  onTap: () async {
                    DateTime? initialDate;
                    if (_dobController.text.isNotEmpty) {
                      initialDate = _parseDateString(_dobController.text);
                    }

                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
                        _validateDOB();
                      });
                    }
                  },
                ),
                SizedBox(height: 10),
                // _buildDateField(),
                Text("City: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                _buildDropdownField(),
                SizedBox(height: 10,),
                _buildGenderSelection(),
                SizedBox(height: 10,),
                _buildHobbiesSelection(),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(onPressed: _submitForm, child: Text(widget.userId != null ? 'Update' : 'Submit')),
                    ElevatedButton(onPressed: _resetForm, child: Text("Reset"))
                  ]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String? errorText, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(), errorText: errorText),
        onChanged: onChanged,
      ),
    );
  }

  // ✅ Date of Birth Field
  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _dobController,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now().subtract(Duration(days: 18 * 365)), // Default to 18 years ago
            firstDate: DateTime.now().subtract(Duration(days: 80 * 365)), // 80 years ago
            lastDate: DateTime.now().subtract(Duration(days: 18 * 365)), // 18 years ago
          );
          if (pickedDate != null) {
            setState(() {
              _dobController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
            });
          }
        },
        validator: (value) {
          if (value!.isEmpty) return 'Date of Birth is required';
          DateTime dob = DateFormat('dd-MM-yyyy').parse(value);
          int age = DateTime.now().year - dob.year;
          return (age >= 18 && age <= 80) ? null : 'Age must be between 18 and 80 years';
        },
      ),
    );
  }

// ✅ City Dropdown
  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: "City", border: OutlineInputBorder()),
        value: _selectedCity,
        items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
        onChanged: (value) => setState(() => _selectedCity = value),
        validator: (value) => value == null ? 'Please select a city' : null,
      ),
    );
  }

// ✅ Gender Selection
  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text("Gender: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile(
                value: "Male",
                groupValue: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value.toString()),
                title: Text("Male"),
              ),
            ),
            Expanded(
              child: RadioListTile(
                value: "Female",
                groupValue: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value.toString()),
                title: Text("Female"),
              ),
            ),
          ],
        ),
      ],
    );
  }

// ✅ Hobbies Selection
  Widget _buildHobbiesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text("Hobbies", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 8.0,
          children: _hobbies.map((hobby) {
            return ChoiceChip(
              label: Text(hobby),
              selected: _selectedHobbies.contains(hobby),
              onSelected: (selected) {
                setState(() {
                  selected ? _selectedHobbies.add(hobby) : _selectedHobbies.remove(hobby);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

}


