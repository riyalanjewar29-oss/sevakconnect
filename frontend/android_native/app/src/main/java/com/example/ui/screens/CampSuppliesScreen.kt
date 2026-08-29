package com.example.ui.screens

import android.widget.Toast
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
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
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakTopAppBar
import com.example.ui.theme.*

enum class CampSupplyStatus {
    SHORTAGE,
    BALANCED,
    SURPLUS
}

enum class RequestStage {
    RAISED,
    PENDING,
    SOLVED
}

data class NearbyCampItem(
    val id: String,
    val campName: String,
    val distance: String,
    val statusText: String,
    val isSurplus: Boolean,
    val updatedTime: String,
    val supplyDetails: String
)

@Composable
fun CampSuppliesScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val isOnline by repository.isOnline.collectAsState()
    val supplies by repository.supplies.collectAsState()

    // 1. Camp Status State
    var campStatus by remember {
        mutableStateOf(if (supplies.isSurplus) CampSupplyStatus.SURPLUS else CampSupplyStatus.BALANCED)
    }
    var mealsCount by remember { mutableIntStateOf(supplies.mealsCount) }
    var waterLiters by remember { mutableIntStateOf(supplies.waterLiters) }
    var lastUpdatedMinutes by remember { mutableIntStateOf(4) }

    // 3 & 4. Tracker & Escalation State
    var activeRequestStage by remember { mutableStateOf<RequestStage?>(RequestStage.PENDING) }
    var requestedCampName by remember { mutableStateOf("Camp Dindi #18 (Alandi)") }
    var isEscalated by remember { mutableStateOf(true) }

    // Nearby Camps dataset
    var nearbyCamps by remember {
        mutableStateOf(
            listOf(
                NearbyCampItem(
                    id = "1",
                    campName = "Camp Dindi #18 (Alandi)",
                    distance = "0.6 km away",
                    statusText = "Surplus Supply",
                    isSurplus = true,
                    updatedTime = "Updated 3m ago",
                    supplyDetails = "+180 Meals • +400L Clean Water"
                ),
                NearbyCampItem(
                    id = "2",
                    campName = "Sant Tukaram Seva Dal #4",
                    distance = "1.1 km away",
                    statusText = "Surplus Supply",
                    isSurplus = true,
                    updatedTime = "Updated 8m ago",
                    supplyDetails = "+90 Meals • +250L Potable Water"
                ),
                NearbyCampItem(
                    id = "3",
                    campName = "Varkari Seva Mandal (Ghat North)",
                    distance = "1.8 km away",
                    statusText = "Surplus Supply",
                    isSurplus = true,
                    updatedTime = "Updated 14m ago",
                    supplyDetails = "+320 Meals • +600L Water Tanker"
                )
            )
        )
    }

    Scaffold(
        topBar = {
            Column {
                SevakTopAppBar(
                    title = "Camp Supplies",
                    showBackButton = true,
                    onBackClick = onBack,
                    isOnline = isOnline,
                    onOfflineToggleClick = { repository.toggleOnlineStatus() }
                )
                OfflineBanner(isOnline = isOnline)
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
            // ==========================================
            // 1. MY CAMP STATUS CARD
            // ==========================================
            Surface(
                shape = RoundedCornerShape(16.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineColor.copy(alpha = 0.3f)),
                shadowElevation = 2.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(18.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    // Header & Timestamp
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = "MY CAMP STATUS",
                                style = MaterialTheme.typography.labelMedium.copy(
                                    fontWeight = FontWeight.Black,
                                    color = VitthalIndigo,
                                    letterSpacing = 1.sp
                                )
                            )
                            Text(
                                text = "Dindi #42 Base Camp (Sector 3)",
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = OnSurfaceVariantColor,
                                    fontWeight = FontWeight.Medium
                                )
                            )
                        }

                        // Timestamp Label
                        Surface(
                            shape = RoundedCornerShape(999.dp),
                            color = TulsiGreenLight
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Outlined.AccessTime,
                                    contentDescription = null,
                                    tint = TulsiGreen,
                                    modifier = Modifier.size(13.dp)
                                )
                                Text(
                                    text = "Last updated ${lastUpdatedMinutes}m ago",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        color = TulsiGreenDark,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 11.sp
                                    )
                                )
                            }
                        }
                    }

                    HorizontalDivider(color = SurfaceVariantColor)

                    // Three-Way Segmented Toggle: Shortage / Balanced / Surplus
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Text(
                            text = "Overall Camp Condition",
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = FontWeight.Bold,
                                color = OnSurfaceColor
                            )
                        )

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(46.dp)
                                .clip(RoundedCornerShape(10.dp))
                                .background(SurfaceContainerHigh)
                                .padding(3.dp),
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            // Shortage (High-Orange)
                            val isShortage = campStatus == CampSupplyStatus.SHORTAGE
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .fillMaxHeight()
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(if (isShortage) StatusHighOrange else Color.Transparent)
                                    .clickable { campStatus = CampSupplyStatus.SHORTAGE }
                                    .testTag("toggle_shortage"),
                                contentAlignment = Alignment.Center
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    if (isShortage) {
                                        Icon(
                                            imageVector = Icons.Default.WarningAmber,
                                            contentDescription = null,
                                            tint = Color.White,
                                            modifier = Modifier.size(15.dp)
                                        )
                                    }
                                    Text(
                                        text = "Shortage",
                                        style = MaterialTheme.typography.labelMedium.copy(
                                            fontWeight = if (isShortage) FontWeight.Bold else FontWeight.Medium,
                                            color = if (isShortage) Color.White else OnSurfaceVariantColor
                                        )
                                    )
                                }
                            }

                            // Balanced (Neutral Outline)
                            val isBalanced = campStatus == CampSupplyStatus.BALANCED
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .fillMaxHeight()
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(if (isBalanced) Color.White else Color.Transparent)
                                    .border(
                                        width = if (isBalanced) 1.5.dp else 0.dp,
                                        color = if (isBalanced) VitthalIndigo else Color.Transparent,
                                        shape = RoundedCornerShape(8.dp)
                                    )
                                    .clickable { campStatus = CampSupplyStatus.BALANCED }
                                    .testTag("toggle_balanced"),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "Balanced",
                                    style = MaterialTheme.typography.labelMedium.copy(
                                        fontWeight = if (isBalanced) FontWeight.Bold else FontWeight.Medium,
                                        color = if (isBalanced) VitthalIndigo else OnSurfaceVariantColor
                                    )
                                )
                            }

                            // Surplus (Normal-Green)
                            val isSurplus = campStatus == CampSupplyStatus.SURPLUS
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .fillMaxHeight()
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(if (isSurplus) StatusNormalGreen else Color.Transparent)
                                    .clickable { campStatus = CampSupplyStatus.SURPLUS }
                                    .testTag("toggle_surplus"),
                                contentAlignment = Alignment.Center
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    if (isSurplus) {
                                        Icon(
                                            imageVector = Icons.Default.Check,
                                            contentDescription = null,
                                            tint = Color.White,
                                            modifier = Modifier.size(15.dp)
                                        )
                                    }
                                    Text(
                                        text = "Surplus",
                                        style = MaterialTheme.typography.labelMedium.copy(
                                            fontWeight = if (isSurplus) FontWeight.Bold else FontWeight.Medium,
                                            color = if (isSurplus) Color.White else OnSurfaceVariantColor
                                        )
                                    )
                                }
                            }
                        }
                    }

                    // Stepper 1: Meals Available
                    LargeSupplyStepper(
                        title = "Meals Available",
                        subtitle = "Packed Bhojan packets for pilgrims",
                        value = mealsCount,
                        unit = "Packets",
                        icon = Icons.Default.Restaurant,
                        step = 10,
                        onIncrement = { mealsCount += 10 },
                        onDecrement = { if (mealsCount >= 10) mealsCount -= 10 }
                    )

                    // Stepper 2: Water (Liters)
                    LargeSupplyStepper(
                        title = "Water (Liters)",
                        subtitle = "Clean drinking water in camp barrels",
                        value = waterLiters,
                        unit = "Liters",
                        icon = Icons.Default.WaterDrop,
                        step = 50,
                        onIncrement = { waterLiters += 50 },
                        onDecrement = { if (waterLiters >= 50) waterLiters -= 50 }
                    )

                    // Broadcast Update Button (Tulsi Green filled)
                    Button(
                        onClick = {
                            lastUpdatedMinutes = 0
                            repository.updateSupplyState(
                                isSurplus = campStatus == CampSupplyStatus.SURPLUS,
                                mealsCount = mealsCount,
                                waterLiters = waterLiters
                            )
                            Toast.makeText(context, "Camp supply update broadcasted to all nearby Wari teams!", Toast.LENGTH_SHORT).show()
                        },
                        colors = ButtonDefaults.buttonColors(
                            containerColor = TulsiGreen,
                            contentColor = Color.White
                        ),
                        shape = RoundedCornerShape(999.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(50.dp)
                            .testTag("broadcast_supplies_button")
                    ) {
                        Icon(
                            imageVector = Icons.Default.Sensors,
                            contentDescription = null,
                            modifier = Modifier.size(18.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Broadcast Update",
                            style = MaterialTheme.typography.labelLarge.copy(
                                fontWeight = FontWeight.Bold,
                                fontSize = 15.sp
                            )
                        )
                    }
                }
            }

            // ==========================================
            // 3 & 4. RAISED → PENDING → SOLVED TRACKER WITH ESCALATED TAG
            // ==========================================
            if (activeRequestStage != null) {
                Surface(
                    shape = RoundedCornerShape(16.dp),
                    color = SurfaceContainerLowest,
                    border = androidx.compose.foundation.BorderStroke(1.dp, OutlineColor.copy(alpha = 0.3f)),
                    shadowElevation = 2.dp,
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("active_supply_tracker_card")
                ) {
                    Column(
                        modifier = Modifier.padding(18.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        // Tracker Header with Target Camp & Controls
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Text(
                                    text = "ACTIVE SUPPLY REQUEST",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = VitthalIndigo,
                                        letterSpacing = 1.sp
                                    )
                                )
                                Text(
                                    text = requestedCampName,
                                    style = MaterialTheme.typography.titleMedium.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = OnSurfaceColor
                                    )
                                )
                            }

                            // Simulation switcher for testing tracker states
                            Surface(
                                shape = RoundedCornerShape(6.dp),
                                color = VitthalIndigoLight,
                                modifier = Modifier.clickable {
                                    activeRequestStage = when (activeRequestStage) {
                                        RequestStage.RAISED -> RequestStage.PENDING
                                        RequestStage.PENDING -> RequestStage.SOLVED
                                        RequestStage.SOLVED -> null
                                        null -> RequestStage.RAISED
                                    }
                                }
                            ) {
                                Text(
                                    text = "Simulate Next",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        color = VitthalIndigo,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 10.sp
                                    ),
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                )
                            }
                        }

                        HorizontalDivider(color = SurfaceVariantColor)

                        // 3-Step Horizontal Stepper Component
                        SupplyProgressTracker(
                            currentStage = activeRequestStage!!,
                            isEscalated = isEscalated,
                            onToggleEscalation = { isEscalated = !isEscalated }
                        )

                        // One-line dynamic status sentence
                        Surface(
                            shape = RoundedCornerShape(10.dp),
                            color = when (activeRequestStage) {
                                RequestStage.RAISED -> TulsiGreenLight
                                RequestStage.PENDING -> if (isEscalated) StatusCriticalRedBg else StatusModerateYellowBg
                                RequestStage.SOLVED -> StatusNormalGreenBg
                                else -> SurfaceContainerHigh
                            },
                            border = androidx.compose.foundation.BorderStroke(
                                width = 1.dp,
                                color = when (activeRequestStage) {
                                    RequestStage.RAISED -> TulsiGreen.copy(alpha = 0.4f)
                                    RequestStage.PENDING -> if (isEscalated) StatusCriticalRed.copy(alpha = 0.5f) else StatusModerateYellow
                                    RequestStage.SOLVED -> StatusNormalGreen.copy(alpha = 0.4f)
                                    else -> OutlineColor
                                }
                            ),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Row(
                                modifier = Modifier.padding(12.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                Icon(
                                    imageVector = when (activeRequestStage) {
                                        RequestStage.RAISED -> Icons.Outlined.Campaign
                                        RequestStage.PENDING -> if (isEscalated) Icons.Default.PriorityHigh else Icons.Outlined.HourglassTop
                                        RequestStage.SOLVED -> Icons.Default.CheckCircle
                                        else -> Icons.Default.Info
                                    },
                                    contentDescription = null,
                                    tint = when (activeRequestStage) {
                                        RequestStage.RAISED -> TulsiGreen
                                        RequestStage.PENDING -> if (isEscalated) StatusCriticalRed else StatusHighOrange
                                        RequestStage.SOLVED -> StatusNormalGreen
                                        else -> OnSurfaceColor
                                    },
                                    modifier = Modifier.size(18.dp)
                                )

                                Text(
                                    text = when (activeRequestStage) {
                                        RequestStage.RAISED -> "Request broadcasted to $requestedCampName. Awaiting volunteer acknowledgment."
                                        RequestStage.PENDING -> if (isEscalated) {
                                            "Escalated: Request pending >15 mins. Alert forwarded to District Supply Cell & QRT."
                                        } else {
                                            "In transit: Seva supply auto-rickshaw dispatched from $requestedCampName (ETA 6 mins)."
                                        }
                                        RequestStage.SOLVED -> "Solved: 100L drinking water & 40 meal packets delivered and verified at camp."
                                        else -> ""
                                    },
                                    style = MaterialTheme.typography.bodySmall.copy(
                                        color = OnSurfaceColor,
                                        fontWeight = FontWeight.Medium,
                                        fontSize = 12.sp
                                    )
                                )
                            }
                        }
                    }
                }
            }

            // ==========================================
            // 2. NEARBY MATCHES LIST
            // ==========================================
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "NEARBY MATCHES (WITHIN 2 KM)",
                        style = MaterialTheme.typography.labelMedium.copy(
                            fontWeight = FontWeight.Black,
                            color = VitthalIndigo,
                            letterSpacing = 0.8.sp
                        )
                    )

                    // Quick Clear / Refresh test toggle
                    Text(
                        text = if (nearbyCamps.isEmpty()) "Show Sample Camps" else "Simulate Empty",
                        style = MaterialTheme.typography.labelSmall.copy(
                            color = VitthalIndigo,
                            fontWeight = FontWeight.Bold,
                            fontSize = 11.sp
                        ),
                        modifier = Modifier
                            .clickable {
                                nearbyCamps = if (nearbyCamps.isEmpty()) {
                                    listOf(
                                        NearbyCampItem(
                                            id = "1",
                                            campName = "Camp Dindi #18 (Alandi)",
                                            distance = "0.6 km away",
                                            statusText = "Surplus Supply",
                                            isSurplus = true,
                                            updatedTime = "Updated 3m ago",
                                            supplyDetails = "+180 Meals • +400L Clean Water"
                                        ),
                                        NearbyCampItem(
                                            id = "2",
                                            campName = "Sant Tukaram Seva Dal #4",
                                            distance = "1.1 km away",
                                            statusText = "Surplus Supply",
                                            isSurplus = true,
                                            updatedTime = "Updated 8m ago",
                                            supplyDetails = "+90 Meals • +250L Potable Water"
                                        )
                                    )
                                } else {
                                    emptyList()
                                }
                            }
                            .padding(4.dp)
                    )
                }

                if (nearbyCamps.isEmpty()) {
                    // Calm Empty State
                    Surface(
                        shape = RoundedCornerShape(16.dp),
                        color = SurfaceContainerLowest,
                        border = androidx.compose.foundation.BorderStroke(1.dp, OutlineColor.copy(alpha = 0.25f)),
                        shadowElevation = 1.dp,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 36.dp, horizontal = 20.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(54.dp)
                                    .clip(CircleShape)
                                    .background(TulsiGreenLight),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Outlined.Inventory2,
                                    contentDescription = null,
                                    tint = TulsiGreen,
                                    modifier = Modifier.size(28.dp)
                                )
                            }

                            Text(
                                text = "No surplus camps found nearby right now.",
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = OnSurfaceColor
                                ),
                                textAlign = TextAlign.Center
                            )

                            Text(
                                text = "All neighboring camps within 2 km are currently in balance. Use 'Broadcast Update' if your camp needs urgent assistance.",
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = OnSurfaceVariantColor,
                                    fontSize = 12.sp
                                ),
                                textAlign = TextAlign.Center
                            )
                        }
                    }
                } else {
                    nearbyCamps.forEach { camp ->
                        NearbySupplyCampCard(
                            camp = camp,
                            onRequest = {
                                requestedCampName = camp.campName
                                activeRequestStage = RequestStage.RAISED
                                isEscalated = false
                                Toast.makeText(
                                    context,
                                    "Supply request dispatched to ${camp.campName}!",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                        )
                    }
                }
            }
        }
    }
}

/**
 * Stepper Component with large centered numbers & high outdoor contrast
 */
@Composable
private fun LargeSupplyStepper(
    title: String,
    subtitle: String,
    value: Int,
    unit: String,
    icon: ImageVector,
    step: Int,
    onIncrement: () -> Unit,
    onDecrement: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(12.dp),
        color = SurfaceContainerLow,
        border = androidx.compose.foundation.BorderStroke(1.dp, OutlineColor.copy(alpha = 0.2f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = TulsiGreen,
                    modifier = Modifier.size(20.dp)
                )
                Column {
                    Text(
                        text = title,
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = OnSurfaceColor
                        )
                    )
                    Text(
                        text = subtitle,
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = OnSurfaceVariantColor,
                            fontSize = 11.sp
                        )
                    )
                }
            }

            // Stepper Row: [-] [ LARGE NUMBER ] [+]
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(58.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                // Minus Button
                Surface(
                    shape = RoundedCornerShape(10.dp),
                    color = Color.White,
                    border = androidx.compose.foundation.BorderStroke(1.5.dp, OutlineColor.copy(alpha = 0.4f)),
                    shadowElevation = 1.dp,
                    modifier = Modifier
                        .size(50.dp)
                        .clickable { onDecrement() }
                        .testTag("stepper_dec_${title.lowercase().replace(" ", "_")}")
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(
                            imageVector = Icons.Default.Remove,
                            contentDescription = "Decrease $title",
                            tint = VitthalIndigo,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                }

                // Centered Value Display
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.weight(1f)
                ) {
                    Text(
                        text = "$value",
                        style = MaterialTheme.typography.displaySmall.copy(
                            fontWeight = FontWeight.Black,
                            color = OnSurfaceColor,
                            fontSize = 30.sp
                        )
                    )
                    Text(
                        text = unit.uppercase(),
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontWeight = FontWeight.Bold,
                            color = VitthalIndigo,
                            fontSize = 10.sp,
                            letterSpacing = 0.5.sp
                        )
                    )
                }

                // Plus Button
                Surface(
                    shape = RoundedCornerShape(10.dp),
                    color = TulsiGreen,
                    shadowElevation = 2.dp,
                    modifier = Modifier
                        .size(50.dp)
                        .clickable { onIncrement() }
                        .testTag("stepper_inc_${title.lowercase().replace(" ", "_")}")
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(
                            imageVector = Icons.Default.Add,
                            contentDescription = "Increase $title",
                            tint = Color.White,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                }
            }
        }
    }
}

/**
 * 3-Step Horizontal Progress Component (Raised -> Pending -> Solved) with Escalation Flag
 */
@Composable
private fun SupplyProgressTracker(
    currentStage: RequestStage,
    isEscalated: Boolean,
    onToggleEscalation: () -> Unit
) {
    // Pulse animation for Pending Moderate-yellow ring when active
    val infiniteTransition = rememberInfiniteTransition(label = "pending_pulse")
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1.0f,
        targetValue = 1.25f,
        animationSpec = infiniteRepeatable(
            animation = tween(900, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse_scale"
    )

    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // STEP 1: Raised (Filled Tulsi Green, Checkmark)
            val isRaisedComplete = currentStage == RequestStage.RAISED ||
                    currentStage == RequestStage.PENDING ||
                    currentStage == RequestStage.SOLVED

            TrackerNode(
                label = "Raised",
                isCompleted = isRaisedComplete,
                isActive = currentStage == RequestStage.RAISED,
                nodeColor = TulsiGreen
            )

            // Connecting Line 1
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(3.dp)
                    .background(
                        if (currentStage == RequestStage.PENDING || currentStage == RequestStage.SOLVED) {
                            TulsiGreen
                        } else {
                            OutlineColor.copy(alpha = 0.3f)
                        }
                    )
            )

            // STEP 2: Pending (Pulsing Moderate-yellow ring when active + Escalated Tag)
            val isPendingActive = currentStage == RequestStage.PENDING
            val isPendingComplete = currentStage == RequestStage.SOLVED

            Box(contentAlignment = Alignment.TopEnd) {
                TrackerNode(
                    label = "Pending",
                    isCompleted = isPendingComplete,
                    isActive = isPendingActive,
                    isPulsing = isPendingActive,
                    pulseScale = pulseScale,
                    activeRingColor = StatusModerateYellow,
                    completedColor = TulsiGreen
                )

                // 4. Escalated Tag if pending too long
                if (isPendingActive && isEscalated) {
                    Surface(
                        shape = RoundedCornerShape(6.dp),
                        color = StatusCriticalRed,
                        shadowElevation = 3.dp, // Level 2 elevation per DESIGN.md
                        border = androidx.compose.foundation.BorderStroke(1.dp, Color.White),
                        modifier = Modifier
                            .offset(x = 18.dp, y = (-10).dp)
                            .clickable { onToggleEscalation() }
                            .testTag("escalated_tag_flag")
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 5.dp, vertical = 2.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(2.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Flag,
                                contentDescription = "Escalated",
                                tint = Color.White,
                                modifier = Modifier.size(10.dp)
                            )
                            Text(
                                text = "ESCALATED",
                                style = MaterialTheme.typography.labelSmall.copy(
                                    color = Color.White,
                                    fontWeight = FontWeight.Black,
                                    fontSize = 9.sp
                                )
                            )
                        }
                    }
                }
            }

            // Connecting Line 2
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(3.dp)
                    .background(
                        if (currentStage == RequestStage.SOLVED) {
                            TulsiGreen
                        } else {
                            OutlineColor.copy(alpha = 0.3f)
                        }
                    )
            )

            // STEP 3: Solved (Filled Tulsi Green, checkmark, muted outline until reached)
            val isSolvedComplete = currentStage == RequestStage.SOLVED
            TrackerNode(
                label = "Solved",
                isCompleted = isSolvedComplete,
                isActive = isSolvedComplete,
                nodeColor = TulsiGreen,
                mutedOutline = !isSolvedComplete
            )
        }
    }
}

@Composable
private fun TrackerNode(
    label: String,
    isCompleted: Boolean,
    isActive: Boolean,
    isPulsing: Boolean = false,
    pulseScale: Float = 1f,
    nodeColor: Color = TulsiGreen,
    activeRingColor: Color = StatusModerateYellow,
    completedColor: Color = TulsiGreen,
    mutedOutline: Boolean = false
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Box(
            modifier = Modifier.size(38.dp),
            contentAlignment = Alignment.Center
        ) {
            // Pulsing Ring for Active Pending
            if (isPulsing) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .scale(pulseScale)
                        .clip(CircleShape)
                        .background(activeRingColor.copy(alpha = 0.25f))
                        .border(2.dp, activeRingColor, CircleShape)
                )
            }

            // Central Node Circle
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(
                        when {
                            isCompleted -> completedColor
                            isActive -> activeRingColor
                            mutedOutline -> Color.White
                            else -> SurfaceContainerHigh
                        }
                    )
                    .border(
                        width = if (mutedOutline) 1.5.dp else 0.dp,
                        color = if (mutedOutline) OutlineColor.copy(alpha = 0.4f) else Color.Transparent,
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (isCompleted) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = "$label completed",
                        tint = Color.White,
                        modifier = Modifier.size(16.dp)
                    )
                } else if (isActive) {
                    Icon(
                        imageVector = Icons.Default.HourglassEmpty,
                        contentDescription = "$label active",
                        tint = Color.White,
                        modifier = Modifier.size(14.dp)
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(OutlineColor.copy(alpha = 0.4f))
                    )
                }
            }
        }

        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall.copy(
                fontWeight = if (isActive || isCompleted) FontWeight.Bold else FontWeight.Medium,
                color = if (isActive || isCompleted) OnSurfaceColor else OnSurfaceVariantColor,
                fontSize = 11.sp
            )
        )
    }
}

/**
 * Nearby Camp Card with Vitthal Indigo outlined button & color-coded status pill
 */
@Composable
private fun NearbySupplyCampCard(
    camp: NearbyCampItem,
    onRequest: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(14.dp),
        color = SurfaceContainerLowest,
        border = androidx.compose.foundation.BorderStroke(1.dp, OutlineColor.copy(alpha = 0.25f)),
        shadowElevation = 1.dp,
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = camp.campName,
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = OnSurfaceColor
                        )
                    )

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Text(
                            text = camp.distance,
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = VitthalIndigo,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        Text(
                            text = "•",
                            style = MaterialTheme.typography.bodySmall.copy(color = OnSurfaceVariantColor)
                        )
                        Text(
                            text = camp.updatedTime,
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = OnSurfaceVariantColor,
                                fontSize = 11.sp
                            )
                        )
                    }
                }

                // Color-Coded Status Pill (Normal/Surplus #2BA84A)
                Surface(
                    shape = RoundedCornerShape(999.dp),
                    color = if (camp.isSurplus) StatusNormalGreenBg else StatusHighOrangeBg,
                    border = androidx.compose.foundation.BorderStroke(
                        1.dp,
                        if (camp.isSurplus) StatusNormalGreen.copy(alpha = 0.4f) else StatusHighOrange.copy(alpha = 0.4f)
                    )
                ) {
                    Text(
                        text = camp.statusText,
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontWeight = FontWeight.Bold,
                            color = if (camp.isSurplus) StatusNormalGreen else StatusHighOrange,
                            fontSize = 11.sp
                        ),
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }
            }

            // Supply details pill
            Surface(
                shape = RoundedCornerShape(8.dp),
                color = SurfaceContainerLow,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(
                        imageVector = Icons.Outlined.CheckCircle,
                        contentDescription = null,
                        tint = TulsiGreen,
                        modifier = Modifier.size(15.dp)
                    )
                    Text(
                        text = camp.supplyDetails,
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = OnSurfaceColor,
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 12.sp
                        )
                    )
                }
            }

            // Vitthal Indigo Outlined Button
            OutlinedButton(
                onClick = onRequest,
                shape = RoundedCornerShape(999.dp),
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = VitthalIndigo
                ),
                border = androidx.compose.foundation.BorderStroke(1.5.dp, VitthalIndigo),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(44.dp)
                    .testTag("request_supply_btn_${camp.id}")
            ) {
                Icon(
                    imageVector = Icons.Default.Send,
                    contentDescription = null,
                    tint = VitthalIndigo,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "Request Supply",
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = VitthalIndigo
                    )
                )
            }
        }
    }
}
