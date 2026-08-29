package com.example.ui.screens

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakBottomNavBar
import com.example.ui.components.SevakTopAppBar
import com.example.ui.navigation.BottomTab
import com.example.ui.navigation.Screen
import com.example.ui.theme.*

@Composable
fun WariRouteMapScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    onNavigate: (String) -> Unit,
    currentTab: BottomTab = BottomTab.MAP,
    onTabSelected: (BottomTab) -> Unit = {},
    modifier: Modifier = Modifier
) {
    val isOnline by repository.isOnline.collectAsState()
    var selectedLanguage by remember { mutableStateOf("EN") }

    Scaffold(
        topBar = {
            Column {
                Surface(
                    color = SurfaceContainerLowest,
                    shadowElevation = 1.dp,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .statusBarsPadding()
                            .height(56.dp)
                            .padding(horizontal = 16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text(
                                text = "Wari Route",
                                style = MaterialTheme.typography.titleLarge.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = PrimaryColor
                                )
                            )
                            // Pulsing Live Badge
                            Surface(
                                shape = RoundedCornerShape(999.dp),
                                color = NormalGreenBg
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Box(modifier = Modifier.size(6.dp).clip(CircleShape).background(NormalGreen))
                                    Text(
                                        text = "LIVE",
                                        style = MaterialTheme.typography.labelSmall.copy(
                                            fontWeight = FontWeight.Bold,
                                            color = NormalGreen,
                                            fontSize = 10.sp
                                        )
                                    )
                                }
                            }
                        }

                        // Language Selector
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            listOf("EN", "मराठी", "हिंदी").forEach { lang ->
                                Surface(
                                    shape = RoundedCornerShape(4.dp),
                                    color = if (selectedLanguage == lang) PrimaryContainerColor else SurfaceContainerHigh,
                                    modifier = Modifier.clickable { selectedLanguage = lang }
                                ) {
                                    Text(
                                        text = lang,
                                        style = MaterialTheme.typography.labelSmall.copy(
                                            fontWeight = FontWeight.Bold,
                                            color = if (selectedLanguage == lang) OnPrimaryContainerColor else OnSurfaceVariantColor
                                        ),
                                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
                                    )
                                }
                            }
                        }
                    }
                }
                OfflineBanner(isOnline = isOnline)
            }
        },
        bottomBar = {
            SevakBottomNavBar(
                currentTab = currentTab,
                onTabSelected = onTabSelected
            )
        },
        containerColor = SurfaceColor,
        modifier = modifier.fillMaxSize()
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Pilgrimage Breadcrumb Progress
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                shadowElevation = 1.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    RouteCheckpoint("Alandi", isPassed = true)
                    Box(modifier = Modifier.width(16.dp).height(2.dp).background(NormalGreen))
                    RouteCheckpoint("Pune", isPassed = true)
                    Box(modifier = Modifier.width(16.dp).height(2.dp).background(PrimaryColor))
                    RouteCheckpoint("Saswad", isCurrent = true)
                    Box(modifier = Modifier.width(16.dp).height(2.dp).background(SurfaceVariantColor))
                    RouteCheckpoint("Pandharpur", isTarget = true)
                }
            }

            // Map Interactive Canvas
            Surface(
                shape = RoundedCornerShape(14.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
            ) {
                Box(modifier = Modifier.fillMaxSize()) {
                    Canvas(modifier = Modifier.fillMaxSize()) {
                        val w = size.width
                        val h = size.height

                        // Route trail curve
                        drawLine(
                            color = PrimaryColor,
                            start = Offset(w * 0.15f, h * 0.15f),
                            end = Offset(w * 0.40f, h * 0.35f),
                            strokeWidth = 10f
                        )
                        drawLine(
                            color = PrimaryColor,
                            start = Offset(w * 0.40f, h * 0.35f),
                            end = Offset(w * 0.55f, h * 0.60f),
                            strokeWidth = 10f
                        )
                        drawLine(
                            color = PrimaryColor.copy(alpha = 0.5f),
                            start = Offset(w * 0.55f, h * 0.60f),
                            end = Offset(w * 0.85f, h * 0.85f),
                            strokeWidth = 8f,
                            pathEffect = PathEffect.dashPathEffect(floatArrayOf(20f, 10f), 0f)
                        )

                        // Hotspots (High congestion area at Dive Ghat)
                        drawCircle(
                            color = CriticalRed.copy(alpha = 0.25f),
                            radius = 45f,
                            center = Offset(w * 0.48f, h * 0.48f)
                        )
                        drawCircle(
                            color = CriticalRed,
                            radius = 12f,
                            center = Offset(w * 0.48f, h * 0.48f)
                        )

                        // Current Position (Saswad)
                        drawCircle(
                            color = PrimaryContainerColor,
                            radius = 24f,
                            center = Offset(w * 0.55f, h * 0.60f)
                        )
                        drawCircle(
                            color = PrimaryColor,
                            radius = 12f,
                            center = Offset(w * 0.55f, h * 0.60f)
                        )

                        // Pandharpur Destination Flag point
                        drawCircle(
                            color = SecondaryColor,
                            radius = 14f,
                            center = Offset(w * 0.85f, h * 0.85f)
                        )
                    }

                    // Floating GPS re-center button
                    IconButton(
                        onClick = { /* Recenter */ },
                        modifier = Modifier
                            .align(Alignment.TopEnd)
                            .padding(12.dp)
                            .background(Color.White, CircleShape)
                            .border(1.dp, OutlineVariantColor, CircleShape)
                    ) {
                        Icon(Icons.Default.MyLocation, contentDescription = "My Location", tint = PrimaryColor)
                    }
                }
            }

            // Congestion Alert Box (Critical Ghat Delay)
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = CriticalRedBg,
                border = androidx.compose.foundation.BorderStroke(1.dp, CriticalRed),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.Top,
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Warning,
                        contentDescription = null,
                        tint = CriticalRed,
                        modifier = Modifier.size(22.dp)
                    )
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Critical Congestion at Dive Ghat",
                            style = MaterialTheme.typography.labelLarge.copy(
                                fontWeight = FontWeight.Bold,
                                color = CriticalRed
                            )
                        )
                        Text(
                            text = "Estimated 2h delay due to bottleneck. Suggested volunteer action: Redirect Dindis to bypass route.",
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = OnSurfaceColor,
                                fontSize = 11.sp
                            )
                        )
                    }
                }
            }

            // Quick Map Actions
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Button(
                    onClick = { onNavigate(Screen.Facilities.route) },
                    colors = ButtonDefaults.buttonColors(containerColor = SecondaryContainerColor, contentColor = OnSecondaryContainerColor),
                    shape = RoundedCornerShape(8.dp),
                    modifier = Modifier.weight(1f).height(44.dp)
                ) {
                    Icon(Icons.Default.CleanHands, contentDescription = null, modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Facilities", style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold))
                }

                Button(
                    onClick = { onNavigate(Screen.ReportCrowd.route) },
                    colors = ButtonDefaults.buttonColors(containerColor = PrimaryColor, contentColor = OnPrimaryColor),
                    shape = RoundedCornerShape(8.dp),
                    modifier = Modifier.weight(1f).height(44.dp)
                ) {
                    Icon(Icons.Default.Groups, contentDescription = null, modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Report Crowd", style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold))
                }
            }
        }
    }
}

@Composable
private fun RouteCheckpoint(
    name: String,
    isPassed: Boolean = false,
    isCurrent: Boolean = false,
    isTarget: Boolean = false
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(2.dp)) {
        Box(
            modifier = Modifier
                .size(16.dp)
                .clip(CircleShape)
                .background(
                    when {
                        isCurrent -> PrimaryContainerColor
                        isPassed -> NormalGreen
                        isTarget -> SecondaryColor
                        else -> SurfaceVariantColor
                    }
                )
        )
        Text(
            text = name,
            style = MaterialTheme.typography.labelSmall.copy(
                fontWeight = if (isCurrent) FontWeight.Bold else FontWeight.Medium,
                color = if (isCurrent) PrimaryColor else OnSurfaceVariantColor,
                fontSize = 10.sp
            )
        )
    }
}
