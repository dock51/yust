import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yust/models/yust_user.dart';
import 'package:yust/screens/sign_in.dart';
import 'package:yust/widgets/yust_focus_handler.dart';
import 'package:yust/widgets/yust_progress_button.dart';
import 'package:yust/widgets/yust_select.dart';

import '../util/yust_exception.dart';
import '../yust.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = '/signUp';
  static const bool signInRequired = false;

  final String homeRouteName;
  final String logoAssetName;
  final bool askForGender;

  SignUpScreen({
    Key key,
    this.homeRouteName = '/',
    this.logoAssetName,
    this.askForGender = false,
  }) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  YustGender _gender;
  String _firstName;
  String _lastName;
  String _email;
  String _password;
  String _passwordConfirmation;
  bool _waitingForSignUp = false;
  void Function() _onSignedIn;

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _passwordConfirmationFocus = FocusNode();

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context).settings.arguments;
    if (arguments is Map) {
      _onSignedIn = arguments['onSignedIn'];
    }

    return YustFocusHandler(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Registrierung'),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                children: <Widget>[
                  _buildLogo(context),
                  _buildGender(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Vorname',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      focusNode: _firstNameFocus,
                      onChanged: (value) => _firstName = value.trim(),
                      onSubmitted: (value) {
                        _firstNameFocus.unfocus();
                        FocusScope.of(context).requestFocus(_lastNameFocus);
                        _scrollController.animateTo(
                            _scrollController.offset + 80,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Nachname',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      focusNode: _lastNameFocus,
                      onChanged: (value) => _lastName = value.trim(),
                      onSubmitted: (value) {
                        _firstNameFocus.unfocus();
                        FocusScope.of(context).requestFocus(_emailFocus);
                        _scrollController.animateTo(
                            _scrollController.offset + 80,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'E-Mail',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      focusNode: _emailFocus,
                      onChanged: (value) => _email = value.trim(),
                      onSubmitted: (value) {
                        _emailFocus.unfocus();
                        FocusScope.of(context).requestFocus(_passwordFocus);
                        _scrollController.animateTo(
                            _scrollController.offset + 80,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Passwort',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      focusNode: _passwordFocus,
                      onChanged: (value) => _password = value.trim(),
                      onSubmitted: (value) async {
                        _passwordFocus.unfocus();
                        FocusScope.of(context)
                            .requestFocus(_passwordConfirmationFocus);
                        _scrollController.animateTo(
                            _scrollController.offset + 80,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Passwort bestätigen',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.send,
                      focusNode: _passwordConfirmationFocus,
                      onChanged: (value) =>
                          _passwordConfirmation = value.trim(),
                      onSubmitted: (value) async {
                        _passwordConfirmationFocus.unfocus();
                        setState(() {
                          _waitingForSignUp = true;
                        });
                        await _signUp(context);
                        setState(() {
                          _waitingForSignUp = false;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: YustProgressButton(
                      color: Theme.of(context).accentColor,
                      inProgress: _waitingForSignUp,
                      onPressed: () => _signUp(context),
                      child: Text('Registrieren',
                          style:
                              TextStyle(fontSize: 20.0, color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, top: 40.0, right: 20.0, bottom: 10.0),
                    child: Text('Du hast bereits einen Account?',
                        style: TextStyle(fontSize: 16.0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, SignInScreen.routeName,
                            arguments: arguments);
                      },
                      child: Text('Hier Anmelden',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    if (widget.logoAssetName == null) {
      return SizedBox.shrink();
    }
    return SizedBox(
      height: 200,
      child: Center(
        child: Image.asset(widget.logoAssetName),
      ),
    );
  }

  Widget _buildGender(BuildContext context) {
    if (!widget.askForGender) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: YustSelect(
        label: 'Anrede',
        value: _gender,
        optionValues: [YustGender.male, YustGender.female],
        optionLabels: ['Herr', 'Frau'],
        onSelected: (value) {
          setState(() {
            _gender = value;
          });
        },
        style: YustInputStyle.outlineBorder,
      ),
    );
  }

  Future<void> _signUp(BuildContext context) async {
    try {
      await Yust.service
          .signUp(
            context,
            _firstName,
            _lastName,
            _email,
            _password,
            _passwordConfirmation,
            gender: _gender,
          )
          .timeout(Duration(seconds: 10));
      if (_onSignedIn != null) _onSignedIn();
      Navigator.popUntil(
        context,
        (route) => ![SignUpScreen.routeName, SignInScreen.routeName]
            .contains(route.settings.name),
      );
    } on YustException catch (err) {
      Yust.service.showAlert(context, 'Fehler', err.message);
    } on PlatformException catch (err) {
      Yust.service.showAlert(context, 'Fehler', err.message);
    } on TimeoutException catch (_) {
      Yust.service.showAlert(
        context,
        'Fehler',
        'Zeitüberschreitung der Anfrage',
      );
    } catch (err) {
      Yust.service.showAlert(context, 'Fehler', err.toString());
    }
  }
}
