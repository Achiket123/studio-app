import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod_base/src/commons/usecases/use_case.dart';
import 'package:flutter_riverpod_base/src/commons/views/otp/login_otp.dart';
import 'package:flutter_riverpod_base/src/core/models/user_model.dart';
import 'package:flutter_riverpod_base/src/core/user.dart';
import 'package:flutter_riverpod_base/src/feature/auth/domain/usecase/use_cases.dart';
import 'package:flutter_riverpod_base/src/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_riverpod_base/src/feature/auth/presentation/pages/sign_up_page.dart';
import 'package:flutter_riverpod_base/src/feature/home/presentation/view/home.dart';
import 'package:flutter_riverpod_base/src/res/colors.dart';
import 'package:flutter_riverpod_base/src/utils/custom_text_button.dart';
import 'package:flutter_riverpod_base/src/utils/form_text_field.dart';
import 'package:go_router/go_router.dart';

class ProfileFormFields extends StatefulWidget {
  final VoidCallback saveImage;
  const ProfileFormFields({super.key, required this.saveImage});

  @override
  State<ProfileFormFields> createState() => _ProfileFormFieldsState();
}

class _ProfileFormFieldsState extends State<ProfileFormFields> {
  String selectedGender = 'male';
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController numberEditingController =
      TextEditingController(text: userDetails['phoneNumber']);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Key textField = const Key('number');
  @override
  void dispose() {
    nameEditingController.dispose();
    numberEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Form(
        key: _formKey,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
              context.go(LoginOtp.routePath);
            }
            if (state is AuthSuccess) {
              user = state.user;
              print(user);
              context.go(HomeView.routePath);
            }
          },
          builder: (context, state) {
            if (state is LoadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormTextField(
                    controller: emailEditingController,
                    labelText: "email",
                  ),
                  FormTextField(
                    controller: nameEditingController,
                    labelText: "Name",
                  ),
                  FormTextField(
                    labelText: "Gender",
                    child: DropdownButton(
                      value: selectedGender,
                      underline: const SizedBox(),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: 'female',
                          onTap: () => setState(() {
                            selectedGender = 'female';
                          }),
                          child: const Text(
                            "Female",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorAssets.blackFaded,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "male",
                          onTap: () => setState(() {
                            selectedGender = 'male';
                          }),
                          child: const Text(
                            "Male",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorAssets.blackFaded,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (data) {},
                    ),
                  ),
                  FormTextField(
                    controller: numberEditingController,
                    labelText: "Phone Number",
                    child: Row(
                      children: [
                        // DropdownButton(
                        //   icon: const Icon(Icons.keyboard_arrow_down_outlined),
                        //   style: const TextStyle(
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w600,
                        //     color: ColorAssets.blackFaded,
                        //   ),
                        //   underline: const SizedBox(),
                        //   items: const [DropdownMenuItem(child: Text("+91"))],
                        //   onChanged: (val) {},
                        // ),
                        Container(
                          margin: const EdgeInsets.only(left: 3, right: 5),
                          height: 20,
                          width: 2,
                          color: ColorAssets.black,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: numberEditingController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                            decoration: const InputDecoration(
                            
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 67),
                    child: CustomTextButton(
                      bgColor: ColorAssets.primaryBlue,
                      text: "Complete Profile",
                      ontap: () {
                        widget.saveImage();

                        if (_formKey.currentState!.validate()) {
                          if (numberEditingController.text.length != 10) {
                            numberEditingController.text = 'invalid number';
                            return;
                          }
                          userDetails.addAll({
                            'createdAt': DateTime.now(),
                            'gender': selectedGender,
                            'email': emailEditingController.text.trim(),
                            'name': nameEditingController.text.trim()
                          });
                          log(userDetails.toString());
                          context.read<AuthBloc>().add(SignUpEvent(
                              params: SignUpParams.fromMap(userDetails)));

                          // context.push(HomeView.routePath);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
