import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/auth_bloc.dart';
import '../../application/bloc/auth_event.dart';
import '../../application/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) =>
          p.error != c.error || p.user != c.user || p.isOtpSent != c.isOtpSent,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        } else if (state.user != null) {
          Navigator.pushReplacementNamed(context, '/todos');
        } else if (state.isOtpSent) {
          Navigator.pushNamed(context, '/otp', arguments: {
            'verificationId': state.verificationId,
            'phone': phoneCtrl.text.trim(),
            'mode': 'login',
            'password': pwdCtrl.text,
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Phone (+91XXXXXXXXXX)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pwdCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            final phone = phoneCtrl.text.trim();
                            context
                                .read<AuthBloc>()
                                .add(AuthSendOtpRequested(phone));
                          },
                    child:
                        Text(state.isLoading ? 'Sending OTP...' : 'Send OTP'),
                  );
                },
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/signup'),
                child: const Text('Create account'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/forgot'),
                child: const Text('Forgot password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
