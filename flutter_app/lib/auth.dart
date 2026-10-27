import 'package:flutter/material.dart';
import 'state.dart';
import 'ui.dart';

class AuthScreen extends StatefulWidget {
  final AppState state;
  const AuthScreen({super.key, required this.state});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController();
  final form = GlobalKey<FormState>();
  String mode = 'login';
  bool submitted = false,
      obscure = true,
      confirmObscure = true,
      busy = false,
      hasErrors = false;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void changeMode(String value) {
    setState(() {
      mode = value;
      submitted = false;
      hasErrors = false;
      password.clear();
      confirm.clear();
      form.currentState?.reset();
    });
  }

  String? validEmail(String? value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
      ? null
      : 'Enter a valid email, like name@example.com.';
  Future<void> signIn({bool guest = false}) async {
    FocusScope.of(context).unfocus();
    if (!guest) {
      setState(() => submitted = true);
      final valid = form.currentState!.validate();
      setState(() => hasErrors = !valid);
      if (!valid) return;
    }
    if (mode == 'reset' && !guest) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Account help'),
          content: const Text(
            'For help accessing your account, contact your barangay office. Keep the email address associated with your profile ready.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                changeMode('login');
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() => busy = true);
    try {
      await widget.state.login(
        mode == 'signup' && !guest ? name.text : widget.state.name,
        guest ? widget.state.email : email.text,
      );
      password.clear();
      confirm.clear();
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Could not save your profile. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget input(
    String label,
    TextEditingController controller,
    String placeholder, {
    String? Function(String?)? validator,
    bool secret = false,
    bool confirming = false,
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        space(8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: secret && (confirming ? confirmObscure : obscure),
          keyboardType: keyboard,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: placeholder,
            suffixIcon: secret
                ? IconButton(
                    tooltip: 'Show or hide password',
                    onPressed: () => setState(() {
                      if (confirming) {
                        confirmObscure = !confirmObscure;
                      } else {
                        obscure = !obscure;
                      }
                    }),
                    icon: Icon(
                      (confirming ? confirmObscure : obscure)
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                    ),
                  )
                : null,
          ),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    if (widget.state.stage == AuthStage.welcome) {
      return Scaffold(
        body: SafeArea(
          child: PageBody(
            children: [
              const Brand(),
              space(45),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset('assets/community.png', fit: BoxFit.cover),
              ),
              space(35),
              eyebrow('A LITTLE CARE GOES A LONG WAY'),
              space(15),
              Text(
                'A cleaner community\nstarts with us.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              space(15),
              const Text(
                'Stay updated, check collection information, and help keep our community clean.',
                style: TextStyle(color: muted, fontSize: 14, height: 1.7),
              ),
              space(38),
              primaryButton(
                'Get Started',
                widget.state.welcomeDone,
                icon: Icons.arrow_forward,
              ),
              space(15),
              const Text(
                'For residents of Purok 3, Barangay Pisaan',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }
    final signup = mode == 'signup', reset = mode == 'reset';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
              child: Form(
                key: form,
                autovalidateMode: submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    eyebrow('PUROK 3 · BARANGAY PISAAN'),
                    space(35),
                    if (signup || reset)
                      TextButton.icon(
                        onPressed: () => changeMode('login'),
                        icon: const Icon(Icons.arrow_back, size: 17),
                        label: const Text('Back to Login'),
                      )
                    else
                      Image.asset('assets/logo.png', width: 56, height: 56),
                    space(25),
                    Text(
                      signup
                          ? 'A cleaner start,\ntogether.'
                          : reset
                          ? 'Let’s get you\nback in.'
                          : 'Welcome back.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    space(13),
                    Text(
                      signup
                          ? 'Create your resident profile for Purok 3, Barangay Pisaan.'
                          : reset
                          ? 'Get help with accessing your account.'
                          : 'Your community, a little closer.\nLog in to stay informed.',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 13,
                        height: 1.7,
                      ),
                    ),
                    space(28),
                    if (hasErrors)
                      const Notice(
                        'Please check the highlighted fields below.',
                        icon: Icons.error_outline,
                      ),
                    if (signup)
                      input(
                        'Full name',
                        name,
                        'Enter your full name',
                        validator: (value) => value?.trim().isNotEmpty == true
                            ? null
                            : 'Enter your full name.',
                      ),
                    input(
                      'Email address',
                      email,
                      'you@example.com',
                      validator: validEmail,
                      keyboard: TextInputType.emailAddress,
                    ),
                    if (!reset)
                      input(
                        'Password',
                        password,
                        signup
                            ? 'At least 8 characters'
                            : 'Enter your password',
                        secret: true,
                        validator: (value) => signup
                            ? ((value?.length ?? 0) >= 8
                                  ? null
                                  : 'Use at least 8 characters.')
                            : (value?.isNotEmpty == true
                                  ? null
                                  : 'Enter your password.'),
                      ),
                    if (signup)
                      input(
                        'Confirm password',
                        confirm,
                        'Re-enter your password',
                        secret: true,
                        confirming: true,
                        validator: (value) => value?.isNotEmpty != true
                            ? 'Please confirm your password.'
                            : value == password.text
                            ? null
                            : 'Passwords do not match.',
                      ),
                    if (!signup && !reset)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => changeMode('reset'),
                          child: const Text(
                            'Account help',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    primaryButton(
                      busy
                          ? 'Please wait…'
                          : signup
                          ? 'Create Account'
                          : reset
                          ? 'Get Account Help'
                          : 'Login',
                      busy ? null : signIn,
                    ),
                    if (!signup && !reset) ...[
                      space(22),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'or',
                              style: TextStyle(color: muted, fontSize: 11),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      space(18),
                      space(15),
                      Center(
                        child: TextButton(
                          onPressed: () => changeMode('signup'),
                          child: const Text(
                            'Don’t have an account? Sign Up',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: busy ? null : () => signIn(guest: true),
                          child: const Text(
                            'Continue as guest →',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                    if (signup)
                      Center(
                        child: TextButton(
                          onPressed: () => changeMode('login'),
                          child: const Text('Already have an account? Login'),
                        ),
                      ),
                    if (reset) ...[
                      space(22),
                      const Notice(
                        'Keep the email address associated with your profile ready.',
                        icon: Icons.mail_outline,
                      ),
                    ],
                    space(22),
                    const Center(
                      child: Text(
                        'A cleaner community starts with us.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          height: 1.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
