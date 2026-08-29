package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.data.repository.SevakRepository
import com.example.ui.navigation.BottomTab
import com.example.ui.navigation.Screen
import com.example.ui.screens.*
import com.example.ui.theme.SevakConnectTheme
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch


class MainActivity : ComponentActivity() {
    private val repository = SevakRepository()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    lifecycleScope.launch {
        try {
            val api = ApiService()
            val result = api.checkBackend()
            println("BACKEND RESPONSE: $result")
        } catch (e: Exception) {
            println("BACKEND ERROR: ${e.message}")
        }
    }

    enableEdgeToEdge()

    setContent {
        SevakConnectTheme {
            SevakApp(repository = repository)
        }
    }
}
}

@Composable
fun SevakApp(repository: SevakRepository) {
    var currentScreen by remember { mutableStateOf<Screen>(Screen.Splash) }
    var currentTab by remember { mutableStateOf(BottomTab.HOME) }
    val backStack = remember { mutableStateListOf<Screen>() }

    fun navigateTo(screen: Screen) {
        if (currentScreen != screen) {
            backStack.add(currentScreen)
            currentScreen = screen
        }
    }

    fun navigateBack() {
        if (backStack.isNotEmpty()) {
            currentScreen = backStack.removeAt(backStack.size - 1)
        } else if (currentScreen != Screen.Home && currentScreen != Screen.Splash) {
            currentScreen = Screen.Home
            currentTab = BottomTab.HOME
        }
    }

    var loginName by remember { mutableStateOf("") }
    var loginMobile by remember { mutableStateOf("") }

    BackHandler(enabled = currentScreen != Screen.Home && currentScreen != Screen.Splash) {
        navigateBack()
    }

    Crossfade(targetState = currentScreen, label = "screen_transition") { screen ->
        when (screen) {
            Screen.Splash -> {
                SplashScreen(
                    onContinue = {
                        navigateTo(Screen.Login)
                    }
                )
            }
            Screen.Login -> {
                LoginScreen(
                    repository = repository,
                    onProceedToOtp = { name, mobile ->
                        loginName = name
                        loginMobile = mobile
                        navigateTo(Screen.OtpVerification)
                    }
                )
            }
            Screen.OtpVerification -> {
                OtpVerificationScreen(
                    repository = repository,
                    name = loginName,
                    mobile = loginMobile,
                    onVerified = {
                        navigateTo(Screen.RoleSetup)
                    },
                    onBackToLogin = {
                        navigateBack()
                    }
                )
            }
            Screen.RoleSetup -> {
                RoleSetupScreen(
                    repository = repository,
                    onRoleConfirmed = {
                        backStack.clear()
                        currentScreen = Screen.Home
                        currentTab = BottomTab.HOME
                    }
                )
            }
            Screen.Home -> {
                HomeScreen(
                    repository = repository,
                    onNavigate = { route ->
                        when (route) {
                            Screen.ReportCrowd.route -> navigateTo(Screen.ReportCrowd)
                            Screen.CampSupplies.route -> navigateTo(Screen.CampSupplies)
                            Screen.Facilities.route -> navigateTo(Screen.Facilities)
                            Screen.ActiveCases.route -> navigateTo(Screen.ActiveCases)
                            Screen.DarshanStatus.route -> navigateTo(Screen.DarshanStatus)
                            Screen.ChandrabhagaZones.route -> navigateTo(Screen.ChandrabhagaZones)
                            Screen.ChatAlerts.route -> {
                                currentTab = BottomTab.CHAT
                                navigateTo(Screen.ChatAlerts)
                            }
                            Screen.Registration.route -> navigateTo(Screen.Registration)
                            Screen.SosAlert.route -> navigateTo(Screen.SosAlert)
                            Screen.RoleSetup.route -> navigateTo(Screen.RoleSetup)
                            Screen.WariRouteMap.route -> {
                                currentTab = BottomTab.MAP
                                navigateTo(Screen.WariRouteMap)
                            }
                        }
                    },
                    currentTab = currentTab,
                    onTabSelected = { tab ->
                        currentTab = tab
                        when (tab) {
                            BottomTab.HOME -> { /* Already home */ }
                            BottomTab.CHAT -> navigateTo(Screen.ChatAlerts)
                            BottomTab.TASKS -> navigateTo(Screen.DarshanStatus)
                            BottomTab.MAP -> navigateTo(Screen.WariRouteMap)
                        }
                    }
                )
            }
            Screen.Registration -> {
                RegistrationScreen(
                    repository = repository,
                    onBack = { navigateBack() }
                )
            }
            Screen.SosAlert -> {
                SosAlertScreen(
                    repository = repository,
                    onBack = { navigateBack() }
                )
            }
            Screen.ChandrabhagaZones -> {
                ChandrabhagaZonesScreen(
                    repository = repository,
                    onBack = { navigateBack() },
                    onNavigateToReport = { navigateTo(Screen.ReportCrowd) }
                )
            }
            Screen.DarshanStatus -> {
                DarshanStatusScreen(
                    repository = repository,
                    onBack = { navigateBack() },
                    onNavigateToMap = {
                        currentTab = BottomTab.MAP
                        navigateTo(Screen.WariRouteMap)
                    }
                )
            }
            Screen.ReportCrowd -> {
                ReportCrowdScreen(
                    repository = repository,
                    onBack = { navigateBack() }
                )
            }
            Screen.ChatAlerts -> {
                ChatAlertsScreen(
                    repository = repository,
                    onBack = { navigateBack() },
                    currentTab = currentTab,
                    onTabSelected = { tab ->
                        currentTab = tab
                        when (tab) {
                            BottomTab.HOME -> {
                                currentScreen = Screen.Home
                            }
                            BottomTab.CHAT -> { /* Already here */ }
                            BottomTab.TASKS -> navigateTo(Screen.DarshanStatus)
                            BottomTab.MAP -> navigateTo(Screen.WariRouteMap)
                        }
                    }
                )
            }
            Screen.CampSupplies -> {
                CampSuppliesScreen(
                    repository = repository,
                    onBack = { navigateBack() }
                )
            }
            Screen.ActiveCases -> {
                ActiveCasesScreen(
                    repository = repository,
                    onBack = { navigateBack() },
                    onReportMissing = { navigateTo(Screen.ReportMissingPerson) }
                )
            }
            Screen.ReportMissingPerson -> {
                ReportMissingPersonScreen(
                    repository = repository,
                    onBack = { navigateBack() }
                )
            }
            Screen.Facilities -> {
                FacilitiesScreen(
                    repository = repository,
                    onBack = { navigateBack() }
                )
            }
            Screen.WariRouteMap -> {
                WariRouteMapScreen(
                    repository = repository,
                    onBack = { navigateBack() },
                    onNavigate = { route ->
                        when (route) {
                            Screen.Facilities.route -> navigateTo(Screen.Facilities)
                            Screen.ReportCrowd.route -> navigateTo(Screen.ReportCrowd)
                            Screen.SosAlert.route -> navigateTo(Screen.SosAlert)
                            else -> {}
                        }
                    },
                    currentTab = currentTab,
                    onTabSelected = { tab ->
                        currentTab = tab
                        when (tab) {
                            BottomTab.HOME -> {
                                currentScreen = Screen.Home
                            }
                            BottomTab.CHAT -> navigateTo(Screen.ChatAlerts)
                            BottomTab.TASKS -> navigateTo(Screen.DarshanStatus)
                            BottomTab.MAP -> { /* Already map */ }
                        }
                    }
                )
            }
        }
    }
}
