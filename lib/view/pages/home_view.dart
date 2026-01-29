import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/auth_repository.dart';
import '../../models/home_event_model.dart';
import '../../models/home_job_model.dart';
import '../../models/home_section_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.accessToken});
  final String accessToken;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool loading = true;
  String? error;
  List<HomeSection> sections = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final repo = context.read<AuthRepository>();
      final res = await repo.getHomeSections(
        accessToken: widget.accessToken,
        search: "",
        pageNumber: 1,
        pageSize: 10,
      );

      if (!mounted) return;
      setState(() {
        sections = res;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: sections.length,
          itemBuilder: (context, i) {
            final s = sections[i];
            final isHorizontal = s.orientation.toLowerCase() == "horizontal";
            final isEvent = s.sectionType.toLowerCase() == "event";

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      s.sectionTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (isHorizontal)
                    SizedBox(
                      height: 170,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: s.dataRaw.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, idx) {
                          final raw = s.dataRaw[idx];
                          if (raw is! Map) return const SizedBox.shrink();
                          final m = raw.cast<String, dynamic>();

                          return isEvent
                              ? EventCard(event: HomeEvent.fromJson(m))
                              : JobCard(job: HomeJob.fromJson(m));
                        },
                      ),
                    )
                  else
                    ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: s.dataRaw.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final raw = s.dataRaw[idx];
                        if (raw is! Map) return const SizedBox.shrink();
                        final m = raw.cast<String, dynamic>();

                        return isEvent
                            ? EventRow(event: HomeEvent.fromJson(m))
                            : JobRow(job: HomeJob.fromJson(m));
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// -------------------- EVENT UI --------------------

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});
  final HomeEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Color(0x11000000)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: event.coverImage.isEmpty
                ? Container(color: const Color(0xFFE5E7EB))
                : Image.network(
                    event.coverImage,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  "${event.startDate} • ${event.locationType}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventRow extends StatelessWidget {
  const EventRow({super.key, required this.event});
  final HomeEvent event;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: event.coverImage.isEmpty
            ? Container(width: 52, height: 52, color: const Color(0xFFE5E7EB))
            : Image.network(
                event.coverImage,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
      ),
      title: Text(event.eventTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text("${event.startDate} • ${event.locationType}"),
    );
  }
}

// -------------------- JOB UI --------------------

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job});
  final HomeJob job;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Color(0x11000000)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.jobTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(job.companyName, style: const TextStyle(color: Colors.black54)),
          const Spacer(),
          Text(
            "${job.jobType} • ${job.workPlaceType}",
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class JobRow extends StatelessWidget {
  const JobRow({super.key, required this.job});
  final HomeJob job;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(job.jobTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text("${job.companyName} • ${job.jobType} • ${job.workPlaceType}"),
    );
  }
}
