import 'package:flutter/material.dart';
import 'package:flutterproject/string_const.dart';
import '../backend/Database.dart';
import 'add_profile_screen.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final MyDatabase _database = MyDatabase.instance; // ✅ Singleton instance
  List<Map<String, dynamic>> _users = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    List<Map<String, dynamic>> allUsers = await _database.getAllUsers();
    setState(() {
      _users = allUsers;
    });
  }

  Future<void> _toggleFavorite(int userId, int currentStatus) async {
    await _database.updateUser(userId, {"isFavorite": currentStatus == 1 ? 0 : 1});
    _fetchUsers();
  }

  Future<void> _deleteUser(int userId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      await _database.deleteUser(userId);
      _fetchUsers();
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _editUser(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProfileScreen(userData: user, userId: user["user_id"]),
      ),
    ).then((_) => _fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredUsers = _users.where((user) {
      return user[FNAME].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user[EMAIL].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user[NUMBER ].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user["dob"].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user[CITY].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user[GENDER].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("All Users",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search users",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(child: Text("No users available"))
                : ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return InkWell(
                  onTap: () {
                    // ✅ Navigate to User Detail Screen when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(userId: user[ID]),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: user[GENDER] == "Male" ? Colors.blue[100] : Colors.pink[100],
                                child: Icon(
                                  user[GENDER] == "Male" ? Icons.male : Icons.female,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user[FNAME]+" "+user[LNAME],
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Divider(thickness: 1, color: Colors.grey[300]),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  user[FAV] == 1 ? Icons.favorite : Icons.favorite_border,
                                  color: user[FAV] == 1 ? Colors.red : Colors.grey,
                                ),
                                onPressed: () => _toggleFavorite(user[ID], user[FAV]),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == "edit") {
                                    _editUser(user);
                                  } else if (value == "delete") {
                                    _deleteUser(user[ID]);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(value: "edit", child: Text("Edit")),
                                  PopupMenuItem(value: "delete", child: Text("Delete")),
                                ],
                                icon: Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.orange, size: 16),
                              SizedBox(width: 5),
                              Text(user[CITY]),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.green, size: 16),
                              SizedBox(width: 5),
                              Text(user[NUMBER]),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.email, color: Colors.red, size: 16),
                              SizedBox(width: 5),
                              Text(user[EMAIL]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
