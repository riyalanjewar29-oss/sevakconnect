package com.example.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakBottomNavBar
import com.example.ui.components.SevakTopAppBar
import com.example.ui.navigation.BottomTab
import com.example.ui.navigation.Screen
import com.example.ui.theme.*

data class QuickActionItem(
    val title: String,
    val icon: ImageVector,
    val route: String
)

@Composable
fun HomeScreen(
    repository: SevakRepository,
    onNavigate: (String) -> Unit,
    currentTab: BottomTab = BottomTab.HOME,
    onTabSelected: (BottomTab) -> Unit = {},
    modifier: Modifier = Modifier
) {
    val isOnline by repository.isOnline.collectAsState()
    val userProfile by repository.userProfile.collectAsState()

    val quickActions = listOf(
        QuickActionItem("Facilities", Icons.Default.CleanHands, Screen.Facilities.route),
        QuickActionItem("Missing Person", Icons.Default.PersonSearch, Screen.ActiveCases.route),
        QuickActionItem("Darshan Status", Icons.Default.Visibility, Screen.DarshanStatus.route),
        QuickActionItem("Chandrabhaga Zones", Icons.Default.Map, Screen.ChandrabhagaZones.route),
        QuickActionItem("Chat", Icons.Default.Forum, Screen.ChatAlerts.route),
        QuickActionItem("Alerts", Icons.Default.NotificationsActive, Screen.ChatAlerts.route),
        QuickActionItem("Darshan Registration", Icons.Default.PersonAdd, Screen.Registration.route),
        QuickActionItem("Report Crowd", Icons.Default.Groups, Screen.ReportCrowd.route),
        QuickActionItem("Camp Supplies", Icons.Default.Inventory2, Screen.CampSupplies.route)
    )

    Scaffold(
        topBar = {
            Column {
                SevakTopAppBar(
                    title = "SevakConnect",
                    showBackButton = false,
                    showAvatar = true,
                    isOnline = isOnline,
                    onAvatarClick = { onNavigate(Screen.RoleSetup.route) },
                    onOfflineToggleClick = { repository.toggleOnlineStatus() }
                )
                OfflineBanner(isOnline = isOnline)
            }
        },
        bottomBar = {
            SevakBottomNavBar(
                currentTab = currentTab,
                onTabSelected = onTabSelected
            )
        },
        floatingActionButton = {
            // Floating Action Button (Red SOS Button matching Image 3.jpeg)
            FloatingActionButton(
                onClick = { onNavigate(Screen.SosAlert.route) },
                containerColor = ErrorColor,
                contentColor = OnErrorColor,
                shape = CircleShape,
                modifier = Modifier
                    .size(60.dp)
                    .testTag("home_sos_fab")
            ) {
                Text(
                    text = "SOS",
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.Black,
                        color = Color.White,
                        fontSize = 16.sp
                    )
                )
            }
        },
        containerColor = SurfaceColor,
        modifier = modifier.fillMaxSize()
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // User Profile Role Header
            Surface(
                shape = RoundedCornerShape(14.dp),
                color = if (userProfile.role == com.example.data.model.UserRole.ADMINISTRATIVE) SecondaryContainerColor.copy(alpha = 0.35f) else PrimaryContainerColor.copy(alpha = 0.35f),
                border = androidx.compose.foundation.BorderStroke(
                    1.dp,
                    if (userProfile.role == com.example.data.model.UserRole.ADMINISTRATIVE) SecondaryColor.copy(alpha = 0.4f) else PrimaryColor.copy(alpha = 0.4f)
                ),
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onNavigate(Screen.RoleSetup.route) }
                    .testTag("user_profile_header")
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(38.dp)
                                .clip(CircleShape)
                                .background(if (userProfile.role == com.example.data.model.UserRole.ADMINISTRATIVE) SecondaryColor else PrimaryColor),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = if (userProfile.role == com.example.data.model.UserRole.ADMINISTRATIVE) Icons.Default.AdminPanelSettings else Icons.Default.VolunteerActivism,
                                contentDescription = null,
                                tint = Color.White,
                                modifier = Modifier.size(20.dp)
                            )
                        }

                        Column {
                            Text(
                                text = userProfile.name.ifEmpty { "Sevak" },
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = OnSurfaceColor
                                )
                            )
                            Text(
                                text = if (userProfile.role == com.example.data.model.UserRole.ADMINISTRATIVE) {
                                    userProfile.adminDepartment.ifEmpty { "Administrative Officer" }
                                } else {
                                    "Volunteer • ${userProfile.affiliation}"
                                },
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = if (userProfile.role == com.example.data.model.UserRole.ADMINISTRATIVE) SecondaryColor else PrimaryColor,
                                    fontWeight = FontWeight.SemiBold
                                )
                            )
                        }
                    }

                    Surface(
                        shape = RoundedCornerShape(999.dp),
                        color = Color.White.copy(alpha = 0.8f)
                    ) {
                        Text(
                            text = "Change Role",
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = FontWeight.Bold,
                                color = OnSurfaceVariantColor,
                                fontSize = 10.sp
                            ),
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                        )
                    }
                }
            }

            // Next Halt Card
            Surface(
                shape = RoundedCornerShape(16.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                shadowElevation = 2.dp,
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("next_halt_card")
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.Top
                    ) {
                        Column {
                            Text(
                                text = "NEXT HALT",
                                style = MaterialTheme.typography.labelSmall.copy(
                                    color = OnSurfaceVariantColor,
                                    fontWeight = FontWeight.Bold,
                                    letterSpacing = 1.sp
                                )
                            )
                            Spacer(modifier = Modifier.height(2.dp))
                            Text(
                                text = "Wakhari Phata",
                                style = MaterialTheme.typography.headlineLarge.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = PrimaryColor,
                                    fontSize = 24.sp
                                )
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Schedule,
                                    contentDescription = null,
                                    tint = OnSurfaceVariantColor,
                                    modifier = Modifier.size(16.dp)
                                )
                                Text(
                                    text = "ETA: 14:30 HRS",
                                    style = MaterialTheme.typography.labelLarge.copy(
                                        color = OnSurfaceVariantColor,
                                        fontWeight = FontWeight.Medium
                                    )
                                )
                            }
                        }

                        // High Crowd Badge
                        Surface(
                            shape = RoundedCornerShape(999.dp),
                            color = PrimaryColor,
                            modifier = Modifier.padding(top = 2.dp)
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Groups,
                                    contentDescription = null,
                                    tint = Color.White,
                                    modifier = Modifier.size(14.dp)
                                )
                                Text(
                                    text = "High Crowd",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        color = Color.White,
                                        fontWeight = FontWeight.Bold
                                    )
                                )
                            }
                        }
                    }

                    // Projected Needs Subcard (Clickable directly to Camp Supplies)
                    Surface(
                        shape = RoundedCornerShape(10.dp),
                        color = SurfaceContainer,
                        border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor.copy(alpha = 0.5f)),
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onNavigate(Screen.CampSupplies.route) }
                            .testTag("projected_needs_card")
                    ) {
                        Column(
                            modifier = Modifier.padding(12.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = "Projected Needs",
                                    style = MaterialTheme.typography.labelLarge.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = OnSurfaceColor
                                    )
                                )
                                Text(
                                    text = "Camp Supplies ›",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = PrimaryColor
                                    )
                                )
                            }

                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                NeedChip(icon = Icons.Default.LocalDrink, text = "Water (200L)")
                                NeedChip(icon = Icons.Default.MedicalServices, text = "Medical (2)")
                                NeedChip(icon = Icons.Default.Wc, text = "Toilets (5)")
                            }
                        }
                    }
                }
            }

            // Quick Actions Header
            Text(
                text = "QUICK ACTIONS",
                style = MaterialTheme.typography.labelLarge.copy(
                    color = OnSurfaceVariantColor,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                ),
                modifier = Modifier.padding(top = 4.dp)
            )

            // 2-Column Grid of Action Cards
            Column(
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                val chunked = quickActions.chunked(2)
                chunked.forEach { rowItems ->
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        rowItems.forEach { item ->
                            Surface(
                                shape = RoundedCornerShape(14.dp),
                                color = SurfaceContainerLowest,
                                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                                shadowElevation = 1.dp,
                                modifier = Modifier
                                    .weight(1f)
                                    .height(96.dp)
                                    .clickable { onNavigate(item.route) }
                                    .testTag("action_${item.title.lowercase().replace(" ", "_")}")
                            ) {
                                Column(
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .padding(12.dp),
                                    horizontalAlignment = Alignment.CenterHorizontally,
                                    verticalArrangement = Arrangement.Center
                                ) {
                                    Icon(
                                        imageVector = item.icon,
                                        contentDescription = item.title,
                                        tint = PrimaryColor,
                                        modifier = Modifier.size(30.dp)
                                    )
                                    Spacer(modifier = Modifier.height(6.dp))
                                    Text(
                                        text = item.title,
                                        style = MaterialTheme.typography.labelLarge.copy(
                                            fontWeight = FontWeight.SemiBold,
                                            color = OnSurfaceColor,
                                            fontSize = 13.sp
                                        ),
                                        textAlign = TextAlign.Center
                                    )
                                }
                            }
                        }
                        if (rowItems.size == 1) {
                            Spacer(modifier = Modifier.weight(1f))
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
private fun NeedChip(
    icon: ImageVector,
    text: String,
    modifier: Modifier = Modifier
) {
    Surface(
        shape = RoundedCornerShape(6.dp),
        color = SurfaceContainerHighest,
        modifier = modifier
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 5.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = OnSurfaceVariantColor,
                modifier = Modifier.size(13.dp)
            )
            Text(
                text = text,
                style = MaterialTheme.typography.labelSmall.copy(
                    fontSize = 11.sp,
                    color = OnSurfaceVariantColor,
                    fontWeight = FontWeight.Medium
                )
            )
        }
    }
}
