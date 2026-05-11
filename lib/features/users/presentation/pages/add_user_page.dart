import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';

/// PAGE 02 — Add User form.
class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});
  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _taste = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _taste.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    context.read<UsersBloc>().add(AddUser(
      name: _name.text.trim(),
      movieTaste: _taste.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is UserAdded) Navigator.of(context).pop();
        if (state is UsersError) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: PopScope(
        canPop: true,
        child: Scaffold(
        appBar: AppBar(title: Text('Add User', style: AppTextStyles.headlineMedium)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 120,
                  margin: const EdgeInsets.only(bottom: AppConstants.paddingLg),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: const Center(child: Icon(Icons.person_add_alt_1, size: 48, color: Colors.white)),
                ),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppConstants.paddingMd),
                TextFormField(
                  controller: _taste,
                  decoration: const InputDecoration(labelText: 'Movie Taste', prefixIcon: Icon(Icons.movie_outlined), hintText: 'e.g. Sci-Fi, Comedy...'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppConstants.paddingXl),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Create User'),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMd),
                Center(
                  child: Text('Works offline — syncs when connected', style: AppTextStyles.bodySmall),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
