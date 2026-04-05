import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axin/cubits/ha_cubit/ha_cubit.dart';
import 'package:axin/cubits/ha_cubit/ha_state.dart';
import 'package:axin/services/ha_service.dart';
import 'package:axin/widgets/security_button.dart';
import 'package:axin/widgets/smart_home_card.dart';
import 'package:axin/widgets/category_card.dart';
import 'package:axin/views/floor1_view.dart';
import 'package:axin/views/qr_setup_view.dart';

class HomeView extends StatefulWidget {
  final String ip;
  final String token;
  final String clientName;

  const HomeView({
    super.key,
    required this.ip,
    required this.token,
    required this.clientName,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HAWebSocketService _service;
  late HAWebSocketService _wsService;
  late HACubit _cubit;

  @override
  void initState() {
    super.initState();
    _service = HAWebSocketService(host: widget.ip, token: widget.token);
    _wsService = HAWebSocketService(host: widget.ip, token: widget.token);
    _cubit = HACubit(_service, _wsService);
    _cubit.fetchData();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ha_ip');
    await prefs.remove('ha_token');
    await prefs.remove('client_name');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const QRSetupView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff160E33),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "AXIN",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'BankGothic',
            fontSize: screenWidth * 0.08,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'logout') {
              _logout();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Disconnect'),
                ],
              ),
            ),
          ],
        ),
        actions: [

          CircleAvatar(
            backgroundImage: const AssetImage("assets/images/person.png"),
            radius: screenWidth * 0.04,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: BlocProvider<HACubit>.value(
        value: _cubit,
        child: BlocBuilder<HACubit, HAState>(
          builder: (context, state) {
            if (state is HALoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HALoaded) {
              final activeDevices = state.devicesStats['activeDevices'] ?? 0;
              final totalDevices = state.devicesStats['totalDevices'] ?? 0;
              final activeScenes = state.devicesStats['activeScenes'] ?? 0;
              final totalScenes = state.devicesStats['totalScenes'] ?? 0;
              final activeAutomations = state.devicesStats['activeAutomations'] ?? 0;
              final totalAutomations = state.devicesStats['totalAutomations'] ?? 0;

              return RefreshIndicator(
                onRefresh: () async {
                  await _cubit.fetchData();
                },
                color: const Color(0xff6C4EFF),
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${widget.clientName} 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.07,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Welcome to Smart Home,',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              onPressed: () {
                                _cubit.fetchData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Refreshing data...'),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Color(0xff6C4EFF),
                                  ),
                                );
                              },
                              tooltip: 'Refresh',
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        SmartHomeCard(
                          activeDevices: activeDevices,
                          totalDevices: totalDevices,
                          activeScenes: activeScenes,
                          totalScenes: totalScenes,
                          activeAutomations: activeAutomations,
                          totalAutomations: totalAutomations,
                          onTap: () {
                            _showStatsDialog(context, state.devicesStats);
                          },
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Row(
                          children: [
                            Text(
                              'Floors',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            SecurityButton(text: "Security"),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        state.floors.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.amber, size: 40),
                              const SizedBox(height: 10),
                              const Text(
                                "No floors found",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _cubit.fetchData(),
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                        )
                            : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.floors.length,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenWidth < 600 ? 2 : 3,
                            crossAxisSpacing: screenWidth * 0.02,
                            mainAxisSpacing: screenHeight * 0.02,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final floor = state.floors[index];
                            final floorId = floor['floor_id'] as String;
                            final floorName = floor['name'] as String;
                            final floorRooms = state.rooms
                                .where((r) => r['floor_id'] == floorId)
                                .toList();

                            return CategoryCard(
                              title: floorName,
                              icon: Icons.home,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider<HACubit>.value(
                                      value: _cubit,
                                      child: FloorOneView(
                                        floorId: floorId,
                                        floorName: floorName,
                                        rooms: floorRooms,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              isActive: true,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is HAError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _cubit.fetchData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context, Map<String, int> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1E1342),
        title: const Text(
          'Device Statistics',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total Devices', stats['totalDevices'] ?? 0),
            _buildStatRow('Active Devices', stats['activeDevices'] ?? 0),
            const Divider(color: Colors.grey),
            _buildStatRow('Total Scenes', stats['totalScenes'] ?? 0),
            _buildStatRow('Active Scenes', stats['activeScenes'] ?? 0),
            const Divider(color: Colors.grey),
            _buildStatRow('Total Automations', stats['totalAutomations'] ?? 0),
            _buildStatRow('Active Automations', stats['activeAutomations'] ?? 0),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xff6C4EFF))),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}