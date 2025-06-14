import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_service.dart';
import 'order_service.dart'; 

class AddressesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мои адреса'),
      ),
      body: Consumer<ProfileService>(
        builder: (context, profileService, child) {
          return FutureBuilder<List<UserAddress>>(
            future: profileService.getAddresses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text('У вас нет сохраненных адресов', style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      Text('Нажмите "+", чтобы добавить новый адрес.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              
              final addresses = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: addresses.length,
                itemBuilder: (ctx, i) => _buildAddressCard(context, addresses[i], profileService),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddressDialog(context),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, UserAddress address, ProfileService service) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(address.isDefault ? Icons.home_work : Icons.location_on_outlined, color: theme.primaryColor),
                SizedBox(width: 12), 
                Expanded(child: Text(address.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                 if (address.isDefault)
                  Chip(
                    label: Text('По умолчанию'),
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(address.fullAddress, style: theme.textTheme.bodyLarge),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Удалить'),
                  style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                  onPressed: () async {
                    await service.deleteAddress(address.id);
                  },
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  child: Text('Изменить'),
                  onPressed: () => _showAddressDialog(context, address: address),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showAddressDialog(BuildContext context, {UserAddress? address}) {
    showDialog<bool>( 
      context: context,
      builder: (_) => AddressFormDialog(address: address), 
    );
  }
}

class AddressFormDialog extends StatefulWidget {
  final UserAddress? address;
  AddressFormDialog({this.address});

  @override
  _AddressFormDialogState createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _city, _street, _house, _apartment;
  late bool _isDefault;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.address?.name ?? 'Дом';
    _city = widget.address?.city ?? '';
    _street = widget.address?.street ?? '';
    _house = widget.address?.house ?? '';
    _apartment = widget.address?.apartment ?? '';
    _isDefault = widget.address?.isDefault ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final service = Provider.of<ProfileService>(context, listen: false);
    final newAddress = UserAddress(
      id: widget.address?.id,
      name: _name,
      city: _city,
      street: _street,
      house: _house,
      apartment: _apartment,
      isDefault: _isDefault,
    );

    try {
      if (widget.address == null) {
        await service.addAddress(newAddress);
      } else {
        await service.updateAddress(newAddress);
      }
      Navigator.of(context).pop(true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      Navigator.of(context).pop(false); 
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.address == null ? 'Новый адрес' : 'Редактировать адрес'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Название (напр. Дом, Работа)'),
                validator: (v) => v!.isEmpty ? 'Введите название' : null,
                onSaved: (v) => _name = v!,
              ),
              SizedBox(height: 12),
              TextFormField(
                initialValue: _city,
                decoration: InputDecoration(labelText: 'Город'),
                validator: (v) => v!.isEmpty ? 'Введите город' : null,
                onSaved: (v) => _city = v!,
              ),
              SizedBox(height: 12),
              TextFormField(
                initialValue: _street,
                decoration: InputDecoration(labelText: 'Улица'),
                validator: (v) => v!.isEmpty ? 'Введите улицу' : null,
                onSaved: (v) => _street = v!,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _house,
                      decoration: InputDecoration(labelText: 'Дом'),
                       validator: (v) => v!.isEmpty ? 'Введите №' : null,
                      onSaved: (v) => _house = v!,
                    ),
                  ),
                  SizedBox(width: 12),
                   Expanded(
                    child: TextFormField(
                      initialValue: _apartment,
                      decoration: InputDecoration(labelText: 'Квартира'),
                       validator: (v) => v!.isEmpty ? 'Введите №' : null,
                      onSaved: (v) => _apartment = v!,
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: Text('Использовать по умолчанию'),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Отмена')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Сохранить'),
        ),
      ],
    );
  }
}