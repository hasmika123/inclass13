import 'package:flutter/material.dart';
import 'dart:math';
import 'success_screen.dart';

class ProgressTracker extends StatefulWidget {
  final bool nameFilled;
  final bool emailFilled;
  final bool passwordFilled;
  final bool dobFilled;
  const ProgressTracker({
    Key? key,
    required this.nameFilled,
    required this.emailFilled,
    required this.passwordFilled,
    required this.dobFilled,
  }) : super(key: key);
  @override
  State<ProgressTracker> createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _message = '';
  @override
  void initState() {
    super.initState();
  _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateProgress());
  }
  @override
  void didUpdateWidget(covariant ProgressTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateProgress();
  }
  void _updateProgress() {
    int filled = [widget.nameFilled, widget.emailFilled, widget.passwordFilled, widget.dobFilled].where((f) => f).length;
    double percent = filled / 4.0;
    String msg = '';
    if (percent >= 1.0) msg = 'Ready for adventure!';
    else if (percent >= 0.75) msg = 'Almost done!';
    else if (percent >= 0.5) msg = 'Halfway there!';
    else if (percent >= 0.25) msg = 'Great start!';
    setState(() {
      _message = msg;
    });
    _controller.animateTo(percent, curve: Curves.easeOut);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _controller.value,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _controller.value >= 1.0 ? Colors.green : Colors.deepPurple,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(_controller.value * 100).round()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _controller.value >= 1.0 ? Colors.green : Colors.deepPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _message,
            key: ValueKey(_message),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _controller.value >= 1.0 ? Colors.green : Colors.deepPurple,
            ),
          ),
        ),
        if (_controller.value >= 0.25 && _controller.value < 0.5)
          _CelebrationIcon(icon: Icons.star, color: Colors.amber),
        if (_controller.value >= 0.5 && _controller.value < 0.75)
          _CelebrationIcon(icon: Icons.emoji_events, color: Colors.orange),
        if (_controller.value >= 0.75 && _controller.value < 1.0)
          _CelebrationIcon(icon: Icons.rocket_launch, color: Colors.blue),
        if (_controller.value >= 1.0)
          _CelebrationIcon(icon: Icons.cake, color: Colors.green),
      ],
    );
  }
}

class _CelebrationIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _CelebrationIcon({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Icon(icon, color: color, size: 32),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _dobFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  late AnimationController _nameShakeController;
  late Animation<double> _nameShakeAnimation;
  late AnimationController _emailShakeController;
  late Animation<double> _emailShakeAnimation;
  String? _nameErrorTooltip;
  String? _emailErrorTooltip;
  bool _isPasswordVisible = false;
  double _passwordStrength = 0.0;
  void _goToNextStep() {
    setState(() {
      _currentStep++;
    });
    if (_currentStep == 1) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    } else if (_currentStep == 2) {
      FocusScope.of(context).requestFocus(_dobFocusNode);
    } else if (_currentStep == 3) {
      FocusScope.of(context).requestFocus(_passwordFocusNode);
    }
  }
  Color get _passwordStrengthColor {
    if (_passwordStrength <= 0.25) return Colors.red;
    if (_passwordStrength <= 0.5) return Colors.orange;
    if (_passwordStrength <= 0.75) return Colors.yellow;
    return Colors.green;
  }
  String get _passwordStrengthLabel {
    if (_passwordStrength <= 0.25) return 'Weak';
    if (_passwordStrength <= 0.5) return 'Fair';
    if (_passwordStrength <= 0.75) return 'Good';
    return 'Strong';
  }
  void _checkPasswordStrength(String password) {
    double strength = 0.0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.25;
    setState(() {
      _passwordStrength = strength;
    });
  }
  bool _isLoading = false;
  int _selectedAvatar = 0;

  final List<IconData> _avatarIcons = [
    Icons.emoji_emotions,
    Icons.pets,
    Icons.face,
    Icons.android,
    Icons.catching_pokemon,
  ];

  @override
  void initState() {
    super.initState();
    _nameShakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _nameShakeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _nameShakeController, curve: Curves.elasticIn));
    _emailShakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _emailShakeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _emailShakeController, curve: Curves.elasticIn));
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        final error = _validateName(_nameController.text);
        if (error != null) {
          setState(() { _nameErrorTooltip = error; });
          _nameShakeController.forward(from: 0);
        } else {
          setState(() { _nameErrorTooltip = null; });
          if (_currentStep == 0) _goToNextStep();
        }
      }
    });
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        final error = _validateEmail(_emailController.text);
        if (error != null) {
          setState(() { _emailErrorTooltip = error; });
          _emailShakeController.forward(from: 0);
        } else {
          setState(() { _emailErrorTooltip = null; });
          if (_currentStep == 1) _goToNextStep();
        }
      }
    });
    _dobFocusNode.addListener(() {
      if (!_dobFocusNode.hasFocus) {
        if (_dobController.text.isNotEmpty) {
          if (_currentStep == 2) _goToNextStep();
        }
      }
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        if (_passwordController.text.isNotEmpty && _passwordController.text.length >= 6) {
          if (_currentStep == 3) _goToNextStep();
        }
      }
    });
  }

  @override
  void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _passwordController.dispose();
  _dobController.dispose();
  _nameFocusNode.dispose();
  _emailFocusNode.dispose();
  _dobFocusNode.dispose();
  _passwordFocusNode.dispose();
  _nameShakeController.dispose();
  _emailShakeController.dispose();
  super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'What should we call you on this adventure?';
    }
    return null;
  }
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'We need your email for adventure updates!';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Oops! That doesn\'t look like a valid email';
    }
    return null;
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              userName: _nameController.text,
              avatarIndex: _selectedAvatar,
              isStrongPassword: _passwordStrength >= 0.75,
              isEarlyBird: DateTime.now().hour < 12,
              isProfileComplete: _nameController.text.isNotEmpty &&
                                _emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty &&
                                _dobController.text.isNotEmpty,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account 🎉'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ProgressTracker(
                  nameFilled: _nameController.text.isNotEmpty,
                  emailFilled: _emailController.text.isNotEmpty,
                  passwordFilled: _passwordController.text.isNotEmpty,
                  dobFilled: _dobController.text.isNotEmpty,
                ),
                const SizedBox(height: 24),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Colors.deepPurple[800]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Complete your adventure profile!',
                          style: TextStyle(
                            color: Colors.deepPurple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text('Choose your avatar:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_avatarIcons.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedAvatar == index ? Colors.deepPurple : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.deepPurple[50],
                            child: Icon(
                              _avatarIcons[index],
                              size: 32,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedBuilder(
                  animation: _nameShakeController,
                  builder: (context, child) {
                    double shake = _nameShakeAnimation.value;
                    double offsetX = _nameErrorTooltip != null
                        ? (sin(shake * 6.0) * (1.0 - shake) * 16)
                        : 0.0;
                    return Transform.translate(
                      offset: Offset(offsetX, 0),
                      child: Stack(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Adventure Name',
                            icon: Icons.person,
                            validator: _validateName,
                            onChanged: (value) {
                              setState(() {});
                              if (_nameErrorTooltip != null && _validateName(value) == null) {
                                _nameShakeController.reset();
                              }
                            },
                            focusNode: _nameFocusNode,
                            highlight: _currentStep == 0,
                          ),
                          if (_nameErrorTooltip != null)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Tooltip(
                                message: _nameErrorTooltip!,
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _emailShakeController,
                  builder: (context, child) {
                    double shake = _emailShakeAnimation.value;
                    double offsetX = _emailErrorTooltip != null
                        ? (sin(shake * 6.0) * (1.0 - shake) * 16)
                        : 0.0;
                    return Transform.translate(
                      offset: Offset(offsetX, 0),
                      child: Stack(
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email,
                            validator: _validateEmail,
                            onChanged: (value) {
                              setState(() {});
                              if (_emailErrorTooltip != null && _validateEmail(value) == null) {
                                _emailShakeController.reset();
                              }
                            },
                            focusNode: _emailFocusNode,
                            highlight: _currentStep == 1,
                          ),
                          if (_emailErrorTooltip != null)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Tooltip(
                                message: _emailErrorTooltip!,
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dobController,
                  focusNode: _dobFocusNode,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _currentStep == 2 ? Colors.orange : Colors.grey,
                        width: _currentStep == 2 ? 2 : 1,
                      ),
                    ),
                    filled: true,
                    fillColor: _currentStep == 2 ? Colors.orange[50] : Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: _selectDate,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'When did your adventure begin?';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Secret Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _currentStep == 3 ? Colors.orange : Colors.grey,
                        width: _currentStep == 3 ? 2 : 1,
                      ),
                    ),
                    filled: true,
                    fillColor: _currentStep == 3 ? Colors.orange[50] : Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  onChanged: _checkPasswordStrength,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Every adventurer needs a secret password!';
                    }
                    if (value.length < 6) {
                      return 'Make it stronger! At least 6 characters';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: _passwordStrength,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Strength: ${_passwordStrengthLabel}',
                        style: TextStyle(
                          color: _passwordStrengthColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : MediaQuery.of(context).size.width,
                  height: 60,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Start My Adventure',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.rocket_launch, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    void Function(String)? onChanged,
    FocusNode? focusNode,
    bool highlight = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: highlight ? Colors.orange : Colors.grey,
            width: highlight ? 2 : 1,
          ),
        ),
        filled: true,
        fillColor: highlight ? Colors.orange[50] : Colors.grey[50],
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}