import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:brew_crew/shared/constants.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0','1','2','3','4'];

  String _currentName;
  String _currentSugars;
  int _currentStrength;

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        
        if(snapshot.hasData){

          UserData userData = snapshot.data;
          return Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    'Update your brew settings',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: userData.name,
                    decoration: textInputDecoration,
                    validator: (val) => val.isEmpty ? 'Please enter a name' : null,
                    onChanged: (val) => setState(() => _currentName = val),
                  ),
                  SizedBox(height: 20),
                  // dropdown
                  DropdownButtonFormField(
                    value: _currentSugars ?? userData.sugars,
                    decoration: textInputDecoration.copyWith(contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10)),
                    items: sugars.map((sugar) {
                      return DropdownMenuItem(
                        value: sugar, 
                        child: Text('$sugar sugar(s)'),
                      );
                    }).toList(), 
                    onChanged: (val) => setState(() => _currentSugars = val),
                  ),
                  SizedBox(height: 20),
                  Slider(
                    activeColor: Colors.brown[_currentStrength ?? userData.strength],
                    inactiveColor: Colors.brown[_currentStrength ?? userData.strength],
                    value: (_currentStrength ?? userData.strength).toDouble(),
                    min: 100,
                    max: 900,
                    divisions: 8,
                    onChanged: (val) => setState(() => _currentStrength = val.round()),
                  ),
                  // slider
                  RaisedButton(
                    color: Colors.brown[400],
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white)
                    ),
                    onPressed: () async {
                      if(_formKey.currentState.validate()){
                        await DatabaseService(uid: user.uid)
                          .updateUserData(
                            _currentSugars ?? userData.sugars, 
                            _currentName ?? userData.name,
                            _currentStrength ?? userData.strength
                          );
                          Navigator.pop(context);
                      }
                    },
                  ),
              ],
            ),
        ),
          );
        } else {
          return Loading();
        }
      }
    );
  }
}