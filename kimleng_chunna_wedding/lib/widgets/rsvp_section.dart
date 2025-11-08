import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/wedding_theme.dart';

class RSVPSection extends StatefulWidget {
  const RSVPSection({super.key});

  @override
  State<RSVPSection> createState() => _RSVPSectionState();
}

class _RSVPSectionState extends State<RSVPSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _guestsController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isAttending = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _guestsController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WeddingColors.accent.withOpacity(0.3),
            WeddingColors.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Column(
        children: [
          // Section title
          Text(
            'RSVP',
            style: WeddingTextStyles.heading2,
            textAlign: TextAlign.center,
          ).animate()
              .fadeIn(delay: 500.ms, duration: 1.seconds)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 10),
          
          Text(
            'Please respond by February 15th, 2025',
            style: WeddingTextStyles.body,
            textAlign: TextAlign.center,
          ).animate()
              .fadeIn(delay: 700.ms, duration: 1.seconds)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 20),
          
          // RSVP Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: WeddingColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: WeddingColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Please enter your name' : null,
                  ).animate()
                      .fadeIn(delay: 1.seconds, duration: 1.seconds)
                      .slideX(begin: -0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address *',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ).animate()
                      .fadeIn(delay: 1.1.seconds, duration: 1.seconds)
                      .slideX(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Attendance toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: WeddingColors.lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          color: WeddingColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Will you be attending?',
                            style: WeddingTextStyles.body,
                          ),
                        ),
                        Switch(
                          value: _isAttending,
                          onChanged: (value) => setState(() => _isAttending = value),
                          activeColor: WeddingColors.primary,
                        ),
                        Text(
                          _isAttending ? 'Yes' : 'No',
                          style: WeddingTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _isAttending ? WeddingColors.primary : WeddingColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 1.2.seconds, duration: 1.seconds)
                      .slideX(begin: -0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Number of guests
                  TextFormField(
                    controller: _guestsController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Guests',
                      prefixIcon: Icon(Icons.group),
                      hintText: 'Including yourself',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isNotEmpty == true) {
                        final guests = int.tryParse(value!);
                        if (guests == null || guests < 1) {
                          return 'Please enter a valid number';
                        }
                      }
                      return null;
                    },
                  ).animate()
                      .fadeIn(delay: 1.3.seconds, duration: 1.seconds)
                      .slideX(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Message field
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message (Optional)',
                      prefixIcon: Icon(Icons.message),
                      hintText: 'Any special requests or messages...',
                    ),
                    maxLines: 3,
                  ).animate()
                      .fadeIn(delay: 1.4.seconds, duration: 1.seconds)
                      .slideX(begin: -0.3),
                  
                  const SizedBox(height: 30),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRSVP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WeddingColors.primary,
                        foregroundColor: WeddingColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(WeddingColors.white),
                              ),
                            )
                          : Text(
                              'Submit RSVP',
                              style: WeddingTextStyles.button,
                            ),
                    ),
                  ).animate()
                      .fadeIn(delay: 1.5.seconds, duration: 1.seconds)
                      .slideY(begin: 0.3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _submitRSVP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isSubmitting = false);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thank you for your RSVP! We look forward to celebrating with you.',
              style: WeddingTextStyles.body.copyWith(color: WeddingColors.white),
            ),
            backgroundColor: WeddingColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Clear form
        _nameController.clear();
        _emailController.clear();
        _guestsController.clear();
        _messageController.clear();
        setState(() => _isAttending = true);
      }
    }
  }
}
