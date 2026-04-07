import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/bottom/controllers/bottom_controller.dart';
import 'package:PregMate/app/modules/home/views/home_view.dart';
import 'package:PregMate/app/modules/profil/views/profil_view.dart';
import 'package:PregMate/app/modules/diskusi/views/diskusi_view.dart';
import 'package:PregMate/app/modules/informasi/views/informasi_view.dart';

class BottomScreen extends GetView<BottomController> {

  const BottomScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() {

      /// pages berdasarkan role
      final pages = controller.role.value == "pendamping"
          ? [
              HomeView(),
              InformasiView(),
              const ProfileView(),
            ]
          : [
              HomeView(),
              DiskusiView(),
              const ProfileView(),
            ];

      return Scaffold(
        extendBody: true,

        body: pages[controller.selectedIndex.value],

        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C2D57).withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),

            child: BottomNavigationBar(
              currentIndex: controller.selectedIndex.value,
              onTap: controller.changeIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF0C2D57),
              unselectedItemColor: const Color(0xFF94A3B8),
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedFontSize: 12,
              selectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w700),
              elevation: 0,

              items: controller.role.value == "pendamping"
                  ? [
                      _buildNavItem(Icons.home_rounded, "Home"),
                      _buildNavItem(Icons.info_rounded, "Informasi"),
                      _buildNavItem(Icons.person_rounded, "Profile"),
                    ]
                  : [
                      _buildNavItem(Icons.home_rounded, "Home"),
                      _buildNavItem(Icons.forum_rounded, "Forum"),
                      _buildNavItem(Icons.person_rounded, "Profile"),
                    ],
            ),
          ),
        ),
      );
    });
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0C2D57).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF0C2D57), size: 24),
      ),
      label: label,
    );
  }
}