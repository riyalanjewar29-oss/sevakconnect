package com.example.ui.navigation

sealed class Screen(val route: String) {
    object Splash : Screen("splash")
    object Login : Screen("login")
    object OtpVerification : Screen("otp_verification")
    object RoleSetup : Screen("role_setup")
    object Home : Screen("home")
    object Registration : Screen("registration")
    object SosAlert : Screen("sos_alert")
    object ChandrabhagaZones : Screen("chandrabhaga_zones")
    object DarshanStatus : Screen("darshan_status")
    object ReportCrowd : Screen("report_crowd")
    object ChatAlerts : Screen("chat_alerts")
    object CampSupplies : Screen("camp_supplies")
    object ActiveCases : Screen("active_cases")
    object ReportMissingPerson : Screen("report_missing_person")
    object Facilities : Screen("facilities")
    object WariRouteMap : Screen("wari_route_map")
}

enum class BottomTab(val title: String, val route: String) {
    HOME("Home", Screen.Home.route),
    CHAT("Chat", Screen.ChatAlerts.route),
    TASKS("Tasks", Screen.DarshanStatus.route),
    MAP("Map", Screen.WariRouteMap.route)
}
