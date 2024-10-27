import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/team.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  Future<List<Team>> getTeams() async {
    try {
      print('Fetching teams...');
      var response = await http.get(
        Uri.parse('https://api.balldontlie.io/v1/teams'),
        headers: {
          'Authorization': 'Your API key here',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<Team> teams = [];
        for (var eachTeam in jsonData['data']) {
          final team = Team(
            abbreviation: eachTeam['abbreviation'],
            city: eachTeam['city'],
          );
          teams.add(team);
        }
        print('Teams fetched successfully.');
        return teams;
      } else {
        print('Failed to load teams. Status code: ${response.statusCode}');
        throw Exception('Failed to load teams');
      }
    } catch (e) {
      print('An error occurred: $e');
      rethrow;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getTeams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final teams = snapshot.data as List<Team>;
              return ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(teams[index].abbreviation),
                        subtitle: Text(teams[index].city),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
