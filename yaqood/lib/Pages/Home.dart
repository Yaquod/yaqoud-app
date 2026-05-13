import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaqood/Constants/constants.dart';
import 'package:yaqood/Widgets/App_Drawer.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
import 'package:yaqood/Widgets/Paymob_WebView.dart';
import 'package:yaqood/Widgets/Primary_color.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:yaqood/Widgets/Trip_Dialog_body.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.initialTripId});
  final String? initialTripId;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  GoogleMapController? mapController;
  DraggableScrollableController sheetController =
      DraggableScrollableController();

  bool hasPermission = false;
  bool isMapMoving = false;
  bool isFirstTime = true;
  bool isSelectedFromSearch = false;
  bool showInfoWindow = true;
  bool hasRoute = false;
  bool isTripDialogShown = false;

  LatLng? startLocation;
  LatLng? currentLocation;
  LatLng? destinationLocation;

  String? startStreetName;
  String? destinationStreetName;
  String? currentTripStatus;
  String? accessToken;

  CameraPosition? lastCameraPosition;
  StreamSubscription<Position>? positionStream;

  TextEditingController startController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  double sheetSize = 0.2;

  FocusNode startFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();

  final _startConfig = GoogleApiConfig(
    apiKey: dotenv.env["GOOGLE_MAPS_API_KEY"]!,
    fetchPlaceDetailsWithCoordinates: true,
  );
  final _destinationConfig = GoogleApiConfig(
    apiKey: dotenv.env["GOOGLE_MAPS_API_KEY"]!,
    fetchPlaceDetailsWithCoordinates: true,
  );

  PolylinePoints polylinePoints = PolylinePoints(
    apiKey: dotenv.env["GOOGLE_MAPS_API_KEY"]!,
  );

  List<LatLng> polylineCoordinates = [];

  Set<Polyline> polylines = {};

  late VoidCallback _startFocusListener;
  late VoidCallback _destinationFocusListener;

  Timer? tripPollingTimer;

  int tripRequestId = 0;

  // Location Permession
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;

      showSnackBar(context: context, message: "Turn on Location Service");

      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return false;

      showSnackBar(context: context, message: "Location permission denied");

      return false;
    }

    return true;
  }

  // Get Streat name from location
  Future<String> getStreetName(LatLng location) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      location.latitude,

      location.longitude,
    );

    if (placemarks.isNotEmpty) {
      return placemarks[0].thoroughfare ?? "Unknown Street";
    }

    return "";
  }

  // assign start Location to it`s textField
  void updatesStartFieldWithStartLocation() async {
    if (currentLocation == null) return;

    String street = await getStreetName(startLocation!);

    setState(() {
      startController.text = street;
    });
  }

  // Location Stream
  void currentLocationStream() async {
    hasPermission = await checkLocationPermission();

    if (!hasPermission) return;

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,

            distanceFilter: 5,
          ),
        ).listen((Position position) async {
          if (!mounted) return;

          LatLng newLatLng = LatLng(position.latitude, position.longitude);
          currentLocation = newLatLng;

          if (startLocation == null && !isSelectedFromSearch && !isMapMoving) {
            String street = await getStreetName(newLatLng);

            setState(() {
              startLocation = newLatLng;
              startStreetName = street;
              startController.text = street;
            });

            mapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));
          }
        });
  }

  //  Location Markers
  Set<Marker> getMarkers() {
    Set<Marker> markersSet = {};

    if (startLocation != null) {
      markersSet.add(
        Marker(
          markerId: MarkerId("start"),
          position: startLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    if (destinationLocation != null) {
      markersSet.add(
        Marker(
          markerId: MarkerId("end"),
          position: destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markersSet;
  }

  // Create route between start and destinatin locations and mange zooming
  void createRoute(LatLng start, LatLng destination) async {
    setState(() {
      showInfoWindow = false;
      hasRoute = true;
    });
    polylineCoordinates.clear();
    polylines.clear();

    RoutesApiRequest request = RoutesApiRequest(
      origin: PointLatLng(start.latitude, start.longitude),
      destination: PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,

      routingPreference: RoutingPreference.trafficAware,
    );

    RoutesApiResponse response = await polylinePoints
        .getRouteBetweenCoordinatesV2(request: request);

    if (response.routes.isNotEmpty) {
      Route route = response.routes.first;

      List<PointLatLng> points = route.polylinePoints ?? [];

      polylineCoordinates = points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
    }

    setState(() {
      polylines.add(
        Polyline(
          polylineId: PolylineId("route"),
          points: polylineCoordinates,
          width: 5,
          color: Colors.blue,
        ),
      );
    });

    if (polylineCoordinates.isNotEmpty) {
      focusOnRoute();
    }
  }

  // FocusOnRoute
  void focusOnRoute() async {
    if (polylineCoordinates.isNotEmpty && mapController != null) {
      double minLat = polylineCoordinates
          .map((p) => p.latitude)
          .reduce((a, b) => a < b ? a : b);

      double maxLat = polylineCoordinates
          .map((p) => p.latitude)
          .reduce((a, b) => a > b ? a : b);

      double minLng = polylineCoordinates
          .map((p) => p.longitude)
          .reduce((a, b) => a < b ? a : b);

      double maxLng = polylineCoordinates
          .map((p) => p.longitude)
          .reduce((a, b) => a > b ? a : b);

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),

        northeast: LatLng(maxLat, maxLng),
      );

      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }

    if (sheetController.isAttached && sheetSize > Constants.minSheetSize) {
      openSheet(Constants.minSheetSize);
    }
  }

  // clear Route
  void clearRoute() {
    setState(() {
      hasRoute = false;
      showInfoWindow = true;
      polylineCoordinates.clear();
      polylines.clear();
    });
  }

  // Clear Destination;
  void clearDestinaton() {
    setState(() {
      destinationController.clear();
      destinationLocation = null;
      destinationStreetName = null;
    });
  }

  // Bottom sheet animation
  void openSheet(double size) {
    if (!sheetController.isAttached) return;

    if ((sheetController.size - size).abs() < 0.02) return;

    sheetController.animateTo(
      size,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Trip Request
  Future<Map<String, dynamic>?> createTrip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      accessToken = await prefs.getString("accessToken");

      print("********************accessToken**********$accessToken");

      if (accessToken == null) {
        showSnackBar(context: context, message: "Login expired");
        return null;
      }

      final response = await post(
        Uri.parse("${dotenv.env["API_BASE_URL"]}/trips/request"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken}',
        },

        body: jsonEncode({
          'startLong': startLocation?.longitude,
          "startLat": startLocation?.latitude,
          "endLong": destinationLocation?.longitude,
          "endLat": destinationLocation?.latitude,
        }),
      );
      print("========================================");
      print("start lat: ${startLocation?.latitude}");
      print("start long: ${startLocation?.longitude}");
      print("========================================");

      return jsonDecode(response.body);
    } catch (e) {
      showSnackBar(context: context, message: "Network error");
      return null;
    }
  }

  // Start Trip Flow
  Future<void> startTripFlow() async {
    final result = await createTrip();

    if (result == null) return;

    if (result["success"] == true) {
      if (result["data"]["status"] == "PENDING") {
        isTripDialogShown = true;

        AwesomeDialog(
          context: context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,

          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,

          body: Column(
            children: [
              Gap(24),

              Text(
                "Finding a nearby Vehicle",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              Gap(10),

              Text(
                "Locating the nearest autonomous taxi",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              Gap(40),
              CircularProgressIndicator(color: PrimaryColor),

              Gap(24),
            ],
          ),
        ).show();

        tripRequestId = result["data"]["id"];

        startTripPolling();
      }
    }
  }

  // get Trip Status
  Future<Map<String, dynamic>?> getTripStatus() async {
    try {
      final response = await get(
        Uri.parse(
          "${dotenv.env["API_BASE_URL"]}/trips/request/status/$tripRequestId",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print("-------------------- status");
      print(response.body);

      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  // start Trip HTTP Polling
  void startTripPolling() {
    tripPollingTimer?.cancel();

    tripPollingTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final result = await getTripStatus();

      if (result == null) return;

      final status = result["data"]['status'];
      final estimatedTime = result["data"]['estimatedTime'];
      final estimatedFare = result["data"]['estimatedFare'];

      currentTripStatus = status;

      handleTripStatus(status, estimatedTime, estimatedFare);
    });
  }

  // Handle Trip Status
  void handleTripStatus(
    String status,
    double estimatedTime,
    double estimatedFare,
  ) {
    if (!mounted) return;

    // if (status != "PENDING") {
    //   tripPollingTimer?.cancel();
    // }

    if (status == "COMPLETED") {
      tripPollingTimer?.cancel();

      if (isTripDialogShown) {
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        isTripDialogShown = false;

        showSnackBar(
          context: context,
          message: "Vehicle Found",
          isError: false,
        );

        AwesomeDialog(
          context: context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,

          dismissOnTouchOutside: true,
          headerAnimationLoop: false,

          btnCancelText: "Reject",
          btnCancelOnPress: () {
            tripPollingTimer?.cancel();
            declineOffer();
          },

          btnOkText: "Accept",
          btnOkOnPress: () {
            tripPollingTimer?.cancel();
            acceptOffer();
          },

          buttonsBorderRadius: BorderRadius.circular(25),
          buttonsTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),

          dialogBorderRadius: BorderRadius.circular(20),

          body: TripDialogBody(
            startStreetName: startStreetName ?? "Unknown Street name",
            destinationStreetName: destinationStreetName!,
            estimatedTime: estimatedTime,
            estimatedFare: estimatedFare,
            declineOffer: declineOffer,
          ),
        ).show();
      }
    }
  }

  // Decline Offer
  Future<Map<String, dynamic>?> declineOffer() async {
    try {
      final response = await post(
        Uri.parse(
          "${dotenv.env["API_BASE_URL"]}/trips/request/$tripRequestId/decline",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken}',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      showSnackBar(context: context, message: "Network error");
      return null;
    }
  }

  // Accept Offer
  Future<Map<String, dynamic>?> acceptOffer() async {
    try {
      final response = await post(
        Uri.parse(
          "${dotenv.env["API_BASE_URL"]}/trips/request/$tripRequestId/accept",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken}',
        },
      );

      final result = jsonDecode(response.body);

      if (result["success"]) {
        if (result["data"]["status"] == "ACCEPTED") {
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          showSnackBar(
            context: context,
            message: "Your vehicle is on the way",
            isError: false,
          );
        } else {
          showSnackBar(context: context, message: "Something went wrong");
        }
      }

      return result;
    } catch (e) {
      showSnackBar(context: context, message: "Network error");
      return null;
    }
  }

  Future<String?> startPayment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      accessToken = prefs.getString("accessToken");

      final response = await post(
        Uri.parse("${dotenv.env["API_BASE_URL"]}/payments/cards"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result["success"] && result["data"] != null) {
          return result["data"]["checkoutUrl"];
        } else {
          if (mounted) {
            showSnackBar(
              context: context,
              message: result["message"] ?? "Error processing payment",
            );
          }
          return null;
        }
      } else {
        if (mounted) {
          showSnackBar(
            context: context,
            message: "Server error: ${response.statusCode}",
          );
        }
        print("Response Body: ${response.body}");
        return null;
      }
    } catch (e) {
      if (mounted) showSnackBar(context: context, message: "Network error: $e");
      return null;
    }
  }

  // init State
  @override
  void initState() {
    super.initState();
    currentLocationStream();

    sheetController.addListener(() {
      if (!mounted) return;

      final newSize = sheetController.size;
      if ((sheetSize - newSize).abs() > 0.01) {
        setState(() {
          sheetSize = newSize;
        });
      }
    });

    _startFocusListener = () {
      if (startFocusNode.hasFocus) {
        openSheet(Constants.maxSheetSize);
      }
    };
    startFocusNode.addListener(_startFocusListener);

    _destinationFocusListener = () {
      if (destinationFocusNode.hasFocus) {
        openSheet(Constants.maxSheetSize);
      }
    };
    destinationFocusNode.addListener(_destinationFocusListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      openSheet(Constants.collapseSheetSize);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // String? status = message.data['status'];
      String title = message.notification?.title ?? "";
      String body = message.notification?.body ?? "";
      print("----------------------------------");
      print("title: $title");
      print("body: $body");
      print("----------------------------------");

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: title,
        desc: body,
        btnOkOnPress: () {},
      ).show();
    });
  }

  // dispose
  @override
  void dispose() {
    startController.dispose();
    destinationController.dispose();

    startFocusNode.removeListener(_startFocusListener);
    destinationFocusNode.removeListener(_destinationFocusListener);

    sheetController.dispose();
    mapController?.dispose();
    positionStream?.cancel();

    tripPollingTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      drawer: AppDrawer(),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator(color: PrimaryColor))
          : Stack(
              children: [
                // Google map
                Positioned.fill(
                  child: GoogleMap(
                    mapType: MapType.normal,

                    markers: getMarkers(),

                    polylines: polylines,

                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,

                    initialCameraPosition: CameraPosition(
                      target: currentLocation!,
                      zoom: 16,
                    ),

                    onTap: (_) {
                      openSheet(Constants.collapseSheetSize);
                    },

                    onCameraMove: (position) {
                      lastCameraPosition = position;

                      if (!isMapMoving) {
                        setState(() => isMapMoving = true);

                        if (isFirstTime) {
                          isFirstTime = false;
                        } else {
                          openSheet(Constants.minSheetSize);
                        }
                      }
                    },

                    onCameraIdle: () async {
                      if (!mounted || lastCameraPosition == null) return;

                      if (isSelectedFromSearch) {
                        setState(() {
                          isSelectedFromSearch = false;
                          isMapMoving = false;
                          if (!hasRoute) {
                            openSheet(Constants.collapseSheetSize);
                          } else {
                            openSheet(Constants.minSheetSize);
                          }
                        });

                        return;
                      }

                      LatLng targetLocation = lastCameraPosition!.target;

                      setState(() {
                        isMapMoving = false;
                      });

                      String street = await getStreetName(targetLocation);
                      if (!hasRoute) {
                        setState(() {
                          startLocation = targetLocation;
                          startStreetName = street;
                          startController.text = street;
                        });

                        openSheet(Constants.collapseSheetSize);
                      }
                    },

                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                ),

                if (!hasRoute)
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isMapMoving ? 10 : 0,
                      height: isMapMoving ? 40 : 0,

                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                  ),

                // info window
                if (startStreetName != null &&
                    !isMapMoving &&
                    sheetSize < 0.5 &&
                    showInfoWindow)
                  Positioned(
                    bottom: (MediaQuery.sizeOf(context).height * 0.5 + 50),
                    left: 0,
                    right: 0,

                    child: Align(
                      alignment: Alignment.topCenter,

                      child: GestureDetector(
                        onTap: () {
                          openSheet(Constants.maxSheetSize);
                        },

                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(10),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Icon(Icons.arrow_back_ios),

                              SizedBox(width: 10),

                              Flexible(
                                fit: FlexFit.loose,

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,

                                  children: [
                                    Text(
                                      "PickUp Location",

                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xffC8C7CC),
                                        height: 0,
                                      ),

                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    Text(
                                      startStreetName ?? "Unknown Street",

                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),

                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Floating button for Drawer
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.easeOut,
                  top:
                      30 -
                      (isMapMoving
                          ? 60
                          : (((sheetSize - 0.8) /
                                        (Constants.maxSheetSize - 0.8))
                                    .clamp(0.0, 1.0) *
                                60)),
                  left: 20,

                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 50),
                    curve: Curves.easeOut,
                    opacity: isMapMoving
                        ? 0
                        : (1 -
                              ((sheetSize - 0.8) /
                                      (Constants.maxSheetSize - 0.8))
                                  .clamp(0.0, 1.0)),

                    child: IgnorePointer(
                      ignoring:
                          sheetSize >= Constants.maxSheetSize || isMapMoving,

                      child: IconButton(
                        onPressed: () {
                          scaffoldKey.currentState?.openDrawer();
                        },

                        icon: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.menu, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating button for Location
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.easeOut,

                  bottom:
                      20 +
                      (isMapMoving
                          ? -20
                          : (MediaQuery.sizeOf(context).height * sheetSize)),
                  right: 20,

                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 50),
                    curve: Curves.easeOut,
                    opacity: isMapMoving ? 0 : (sheetSize >= 0.8 ? 0 : 1),

                    child: IgnorePointer(
                      ignoring: sheetSize >= 0.8 || isMapMoving,

                      child: FloatingActionButton.small(
                        heroTag: "hero-1",
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),

                        onPressed: () {
                          if (currentLocation == null) return;

                          if (hasRoute) {
                            clearRoute();
                            hasRoute = false;
                            startLocation = currentLocation;
                            clearDestinaton();
                          }
                          mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(currentLocation!, 16),
                          );
                        },

                        child: hasRoute
                            ? Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Colors.black,
                              )
                            : Icon(
                                Icons.location_searching,
                                size: 20,
                                color: Colors.black,
                              ),
                      ),
                    ),
                  ),
                ),

                // floating button for focusOnRoute
                if (hasRoute && polylineCoordinates.isNotEmpty)
                  Positioned(
                    bottom:
                        20 +
                        (isMapMoving
                            ? -20
                            : (MediaQuery.sizeOf(context).height * sheetSize)),
                    left: 20,
                    child: FloatingActionButton.small(
                      heroTag: "hero-2",
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),

                      onPressed: () {
                        focusOnRoute();
                      },

                      child: const Icon(
                        Icons.route,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),

                // Bottom Sheet
                DraggableScrollableSheet(
                  controller: sheetController,

                  initialChildSize: Constants.collapseSheetSize,
                  minChildSize: Constants.minSheetSize,
                  maxChildSize: Constants.maxSheetSize,

                  builder: (context, scrollController) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),

                      child: ListView(
                        controller: scrollController,

                        children: [
                          Icon(Icons.drag_handle),

                          Gap(10),

                          // start Location textField
                          GooglePlacesAutoCompleteTextFormField(
                            key: const ValueKey("startLocation"),
                            config: _startConfig,
                            textEditingController: startController,
                            focusNode: startFocusNode,

                            decoration: InputDecoration(
                              labelText: "Pick up Location",
                              focusColor: PrimaryColor,

                              border: OutlineInputBorder(),

                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: PrimaryColor,
                                  width: 1,
                                ),
                              ),

                              suffixIcon: startController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() {
                                          startController.clear();
                                          startLocation = null;
                                          startStreetName = null;
                                          clearRoute();
                                        });
                                      },
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.grey.shade700,
                                      ),
                                    )
                                  : null,
                            ),

                            maxLines: 1,
                            minInputLength: 3,

                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter some text';
                              }

                              return null;
                            },

                            overlayContainerBuilder: (child) => Material(
                              elevation: 5,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),

                              child: child,
                            ),

                            onPredictionWithCoordinatesReceived:
                                (Prediction prediction) {
                                  if (prediction.lat == null ||
                                      prediction.lng == null) {
                                    return;
                                  }

                                  final LatLng selectedLocation = LatLng(
                                    double.parse(prediction.lat!),
                                    double.parse(prediction.lng!),
                                  );

                                  FocusScope.of(context).unfocus();

                                  setState(() {
                                    isSelectedFromSearch = true;
                                    startLocation = selectedLocation;
                                    startStreetName = prediction.description
                                        ?.split('،')[0];
                                    startController.text =
                                        prediction.description!;

                                    clearRoute();
                                  });

                                  mapController?.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      selectedLocation,
                                      16,
                                    ),
                                  );
                                },

                            onSuggestionClicked: (Prediction prediction) {
                              startController.text = prediction.description!;

                              if (startLocation != null &&
                                  destinationLocation != null) {
                                openSheet(Constants.minSheetSize);

                                createRoute(
                                  startLocation!,
                                  destinationLocation!,
                                );

                                startTripFlow();
                              }
                            },
                          ),

                          Gap(20),

                          // Destination Location textField
                          GooglePlacesAutoCompleteTextFormField(
                            key: const ValueKey("destinationKey"),
                            config: _destinationConfig,
                            textEditingController: destinationController,
                            focusNode: destinationFocusNode,

                            decoration: InputDecoration(
                              labelText: "What is your Destination ?",
                              focusColor: PrimaryColor,

                              border: OutlineInputBorder(),

                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: PrimaryColor,
                                  width: 1,
                                ),
                              ),

                              suffixIcon: destinationController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        clearDestinaton();
                                        setState(() {
                                          clearRoute();
                                        });
                                        mapController?.animateCamera(
                                          CameraUpdate.newLatLngZoom(
                                            currentLocation!,
                                            16,
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.grey.shade700,
                                      ),
                                    )
                                  : null,
                            ),

                            maxLines: 1,
                            minInputLength: 3,

                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Choose your destination';
                              }

                              return null;
                            },

                            overlayContainerBuilder: (child) => Material(
                              elevation: 5,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),

                              child: child,
                            ),

                            onPredictionWithCoordinatesReceived:
                                (Prediction prediction) {
                                  if (prediction.lat == null ||
                                      prediction.lng == null) {
                                    return;
                                  }

                                  final LatLng selectedLocation = LatLng(
                                    double.parse(prediction.lat!),
                                    double.parse(prediction.lng!),
                                  );

                                  FocusScope.of(context).unfocus();

                                  setState(() {
                                    isSelectedFromSearch = true;
                                    destinationLocation = selectedLocation;
                                    destinationStreetName = prediction
                                        .description
                                        ?.split('،')[0];
                                    destinationController.text =
                                        prediction.description!;

                                    clearRoute();
                                  });

                                  if (startLocation != null &&
                                      destinationLocation != null) {
                                    openSheet(Constants.minSheetSize);

                                    createRoute(
                                      startLocation!,
                                      destinationLocation!,
                                    );

                                    startTripFlow();
                                  }
                                },

                            onSuggestionClicked: (Prediction prediction) {
                              destinationController.text =
                                  prediction.description!;
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                Center(
                  child: MaterialButton(
                    onPressed: () async {
                      String? url = await startPayment();

                      if (url != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => PaymobWebView(url: url),
                          ),
                        );
                      }
                    },
                    color: Colors.lightBlue,
                    child: Text("Pay for Yaquod"),
                  ),
                ),
              ],
            ),
    );
  }
}
