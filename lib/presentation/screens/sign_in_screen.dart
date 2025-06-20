import 'package:clear_task/presentation/screens/home_screen.dart';
import 'package:clear_task/presentation/widgets/auth_footer.dart';
import 'package:clear_task/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _globalKey = GlobalKey();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _globalKey,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Image.asset("assets/icons/clear_task_icon_png.png",  height: 100),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'It\'s great to have you back with us again!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    validationLabel: "Email",
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(
                      HugeIcons.strokeRoundedMail01,
                      color: Colors.grey.shade600,
                    ),
                    validator: (email) {
                      if (email == null || email.isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex =
                      RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                      if (!emailRegex.hasMatch(email)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    validationLabel: "Password",
                    isRequired: true,
                    keyboardType: TextInputType.text,
                    obscureText: isPasswordVisible ? false : true,
                    prefixIcon: Icon(
                      HugeIcons.strokeRoundedLockPassword,
                      color: Colors.grey.shade600,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      icon: isPasswordVisible
                          ? Icon(Icons.visibility_off,
                          color: Colors.grey.shade600)
                          : Icon(Icons.visibility, color: Colors.grey.shade600),
                    ),
                    validator: (password) {
                      if (password == null || password.isEmpty) {
                        return 'Password is required';
                      }
                      if (password.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        //if (_globalKey.currentState?.validate() ?? false) {
                        Get.offAll(() => const HomeScreen());
                        //}
                      },
                      child: const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthFooter(
                    label: 'Don\'t have an account?  ',
                    actionText: 'Sign Up',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}