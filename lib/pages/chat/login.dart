import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/chat/user_image_picker.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/services/shared/errors.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/widgets/shared/simple_error_dialog.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => LoginState();
}

enum LoginStatus { signIn, create }

class LoginState extends ConsumerState<Login> {
  LoginStatus _status = LoginStatus.signIn;
  late List<TextEditingController> _textEditingControllers;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _textEditingControllers = List<TextEditingController>.generate(
        3, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (final item in _textEditingControllers) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: SizedBox(
                height: size.width / 2,
                width: size.width / 2,
                child: Image.asset('assets/images/chat/main.png')),
          ),
          const SizedBox(height: 16),
          Builder(builder: (context) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.3),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: [
                    if (_status == LoginStatus.create)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: UserImagePicker(
                          selectType: ImageSource.camera,
                          onSelected: (p0) => _selectedImage = p0,
                        ),
                      ),
                    TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.singleLineFormatter
                      ],
                      controller: _textEditingControllers.first,
                      decoration: const InputDecoration(
                          label: Text("email"), border: InputBorder.none),
                      validator: (value) {
                        if (value != null) {
                          if (RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                            return null;
                          }
                          return 'Please type correct email format';
                        }
                        return 'Please type email';
                      },
                    ),
                    _status == LoginStatus.create
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.singleLineFormatter
                              ],
                              controller: _textEditingControllers[1],
                              decoration: const InputDecoration(
                                  label: Text("username"),
                                  border: InputBorder.none),
                              validator: (value) {
                                if (value != null) {
                                  return null;
                                }
                                return 'Please type username';
                              },
                            ),
                          )
                        : const SizedBox(height: 10.0),
                    TextFormField(
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.singleLineFormatter
                        ],
                        controller: _textEditingControllers.last,
                        validator: (value) {
                          if (value != null && value.length >= 8) {
                            return null;
                          }
                          return 'password length is less than 8';
                        },
                        decoration: const InputDecoration(
                            label: Text("password"), border: InputBorder.none)),
                    const SizedBox(height: 10.0),
                    FilledButton(
                        onPressed: () async {
                          if (_status == LoginStatus.signIn) {
                            if (Form.of(context).validate()) {
                              final result = await ref.read(chatService).signIn(
                                  _textEditingControllers.first.text,
                                  _textEditingControllers.last.text);
                              if (result is bool) {
                              } else if (result is AuthError) {
                                final error = result;
                                showDialog(
                                    context: context,
                                    builder: (context) => SimpleErrorDialog(
                                        message: error.message,
                                        title: "Sign In Error"));
                              }
                            }
                          } else {
                            final validate = Form.of(context).validate();
                            if (validate && _selectedImage != null) {
                              final result = await ref
                                  .read(chatService)
                                  .createAccount(
                                      _textEditingControllers.first.text,
                                      _textEditingControllers.last.text,
                                      _selectedImage!,
                                      _textEditingControllers[1].text);
                              if (result is AuthError) {
                                final error = result;
                                showDialog(
                                    context: context,
                                    builder: (context) => SimpleErrorDialog(
                                        message: error.message,
                                        title: "Create user Error"));
                              }
                            }
                          }
                        },
                        child: Text(_status == LoginStatus.signIn
                            ? "Sign In"
                            : "Create account")),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () => setState(() {
                                  _status = _status == LoginStatus.signIn
                                      ? LoginStatus.create
                                      : LoginStatus.signIn;
                                  _selectedImage = null;
                                }),
                            child: Text(_status == LoginStatus.signIn
                                ? "Create Account"
                                : "Already have account?")),
                        _status == LoginStatus.signIn
                            ? TextButton(
                                onPressed: () {},
                                child: const Text("Forget password?"))
                            : const SizedBox()
                      ],
                    )
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
