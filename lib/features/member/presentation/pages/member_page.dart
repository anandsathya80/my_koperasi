import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/member_provider.dart';
import '../../data/models/member_model.dart';
import 'member_detail_page.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MemberProvider>(context);

    final members = provider.members
        .where((m) => m.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Member Tabungan",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: "Cari member...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // LIST / EMPTY
          Expanded(
            child: members.isEmpty
                ? _emptyState()
                : ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _memberCard(context, member);
                    },
                  ),
          ),
        ],
      ),

      // ➕ FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        backgroundColor: Colors.blueAccent,
        label: const Text("Tambah"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // 🎴 MEMBER CARD
  Widget _memberCard(BuildContext context, Member member) {
    final provider = Provider.of<MemberProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemberDetailPage(member: member),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

          // 👤 AVATAR
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : "?",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),

          title: Text(
            member.name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            member.phone,
            style: const TextStyle(color: Colors.white70),
          ),

          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                _showForm(context, member: member);
              } else if (value == 'delete') {
                try {
                  provider.deleteMember(member.id);
                  _showSnackBar(context, "Member berhasil dihapus 🗑️");
                } catch (e) {
                  _showSnackBar(context, "Gagal menghapus!", isError: true);
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text("Edit")),
              PopupMenuItem(value: 'delete', child: Text("Hapus")),
            ],
          ),
        ),
      ),
    );
  }

  // 😶 EMPTY STATE
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.group, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Belum ada member",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 🔔 SNACKBAR
  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // 📝 FORM (FIX KEYBOARD + MODERN)
  void _showForm(BuildContext context, {Member? member}) {
    final nameController = TextEditingController(text: member?.name ?? "");
    final phoneController = TextEditingController(text: member?.phone ?? "");

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      ),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          member == null ? "Tambah Member" : "Edit Member",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // FORM
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v!.isEmpty ? "Nama wajib diisi" : null,
                            decoration: InputDecoration(
                              labelText: "Nama",
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: phoneController,
                            textInputAction: TextInputAction.done,
                            validator: (v) =>
                                v!.isEmpty ? "No HP wajib diisi" : null,
                            decoration: InputDecoration(
                              labelText: "No HP",
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate()) {
                                  _showSnackBar(context, "Form belum lengkap!",
                                      isError: true);
                                  return;
                                }

                                final provider = Provider.of<MemberProvider>(
                                    context,
                                    listen: false);

                                try {
                                  if (member == null) {
                                    provider.addMember(
                                      nameController.text,
                                      phoneController.text,
                                    );
                                    _showSnackBar(context,
                                        "Member berhasil ditambahkan ✅");
                                  } else {
                                    provider.updateMember(
                                      member,
                                      nameController.text,
                                      phoneController.text,
                                    );
                                    _showSnackBar(
                                        context, "Member berhasil diupdate ✏️");
                                  }

                                  Navigator.pop(context);
                                } catch (e) {
                                  _showSnackBar(context, "Terjadi kesalahan!",
                                      isError: true);
                                }
                              },
                              child: Text(member == null ? "Simpan" : "Update"),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
