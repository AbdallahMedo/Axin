import 'package:axin/views/air_conditioner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/get_weather_cubit/get_weather_cubit.dart';
import '../cubits/get_weather_cubit/get_weather_states.dart';
import '../model/weather_model.dart';

class RoomOneView extends StatefulWidget {
  const RoomOneView({super.key});

  @override
  _RoomOneViewState createState() => _RoomOneViewState();
}

class _RoomOneViewState extends State<RoomOneView> {
  bool isLightsExpanded = false;
  bool isCurtainsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff160E33),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Room One',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<GetWeatherCubit, WeatherState>(
                  builder: (context ,state)

                  {
                    if(state is WeatherLoadedState)
                    {
                      return _TemperatureCard(weaher: state.weatherModel);
                    }
                    return const SizedBox();
                  }
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isLightsExpanded = !isLightsExpanded;
                  });
                },
                child: _SwitchTile(
                  title: 'Lights',
                  icon: Icons.lightbulb_outline,
                  trailing: Icon(
                    isLightsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isLightsExpanded) ...[
                _SwitchTile(title: 'Light 1'),
                _SwitchTile(title: 'Light 2'),
                _SwitchTile(title: 'Light 3'),
              ],
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCurtainsExpanded = !isCurtainsExpanded;
                  });
                },
                child: _SwitchTile(
                  title: 'Curtains',
                  icon: Icons.window,
                  trailing: Icon(
                    isCurtainsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isCurtainsExpanded) ...[
                _SwitchTile(title: 'Curtain 1'),
                _SwitchTile(title: 'Curtain 2'),
              ],
              const SizedBox(height: 16),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blueGrey[800],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.ac_unit,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Air Conditioner",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      Spacer(),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return AirConditionerView();
                                },
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.settings,
                            color: Colors.white,
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemperatureCard extends StatelessWidget {
  final WeatherModel weaher;

  const _TemperatureCard({super.key, required this.weaher});
  @override
  Widget build(BuildContext context) {
    WeatherModel weatherModel=BlocProvider.of<GetWeatherCubit>(context).weatherModel!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:  [
          Text('${weatherModel.tempC}°',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SensorInfo(label: 'CO2', value: '20%'),
              _SensorInfo(label: 'Precipitation', value: '4%'),
              _SensorInfo(label: 'Humidity', value: '${weatherModel.humidity}%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SensorInfo extends StatelessWidget {
  final String label;
  final String value;

  const _SensorInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

class _SwitchTile extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final Color? backgroundColor;

  const _SwitchTile(
      {required this.title,
      this.icon,
      this.trailing,
      this.backgroundColor,
      Key? key})
      : super(key: key);

  @override
  _SwitchTileState createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        tileColor: widget.backgroundColor ?? Colors.blueGrey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading:
            widget.icon != null ? Icon(widget.icon, color: Colors.white) : null,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        trailing: widget.trailing ??
            Switch(
              value: isSwitched,
              onChanged: (value) => setState(() => isSwitched = value),
              activeColor: Colors.green,
            ),
      ),
    );
  }
}

class _TemperatureControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.settings, color: Colors.white),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () {},
              ),
              const Text('22°',
                  style: TextStyle(fontSize: 24, color: Colors.white)),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
