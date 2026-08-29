package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.ChatMessage
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakBottomNavBar
import com.example.ui.components.SevakTopAppBar
import com.example.ui.navigation.BottomTab
import com.example.ui.theme.*

@Composable
fun ChatAlertsScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    currentTab: BottomTab = BottomTab.CHAT,
    onTabSelected: (BottomTab) -> Unit = {},
    modifier: Modifier = Modifier
) {
    val isOnline by repository.isOnline.collectAsState()
    val allMessages by repository.chatMessages.collectAsState()

    var selectedChatCategory by remember { mutableStateOf("General") }
    var inputText by remember { mutableStateOf("") }

    val categories = listOf("General", "Medical Escalation", "Police Liaison")
    val filteredMessages = allMessages.filter {
        it.category == selectedChatCategory || it.isSystemAlert
    }

    Scaffold(
        topBar = {
            Column {
                SevakTopAppBar(
                    title = "Chat & Alerts",
                    showBackButton = true,
                    onBackClick = onBack,
                    isOnline = isOnline,
                    onOfflineToggleClick = { repository.toggleOnlineStatus() }
                )
                OfflineBanner(
                    isOnline = isOnline,
                    customText = "Working Offline - Messages will sync when reconnected"
                )
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
        ) {
            // Category Tabs
            Surface(
                color = SurfaceContainerLowest,
                shadowElevation = 1.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 6.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    categories.forEach { cat ->
                        val isSelected = selectedChatCategory == cat
                        Surface(
                            shape = RoundedCornerShape(999.dp),
                            color = if (isSelected) SecondaryContainerColor else SurfaceContainerHigh,
                            modifier = Modifier
                                .clickable { selectedChatCategory = cat }
                                .testTag("chat_tab_${cat.lowercase().replace(" ", "_")}")
                        ) {
                            Text(
                                text = cat,
                                style = MaterialTheme.typography.labelSmall.copy(
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                    color = if (isSelected) OnSecondaryContainerColor else OnSurfaceVariantColor
                                ),
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                            )
                        }
                    }
                }
            }

            // Message Stream
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(filteredMessages) { msg ->
                    ChatBubble(message = msg)
                }
            }

            // Input Bar
            Surface(
                color = SurfaceContainerLowest,
                shadowElevation = 4.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = inputText,
                        onValueChange = { inputText = it },
                        placeholder = { Text("Type message or alert...") },
                        shape = RoundedCornerShape(24.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = PrimaryColor,
                            unfocusedBorderColor = OutlineColor.copy(alpha = 0.5f)
                        ),
                        modifier = Modifier
                            .weight(1f)
                            .height(50.dp)
                            .testTag("chat_input_field")
                    )

                    IconButton(
                        onClick = {
                            if (inputText.isNotBlank()) {
                                repository.sendChatMessage(inputText, selectedChatCategory)
                                inputText = ""
                            }
                        },
                        modifier = Modifier
                            .size(44.dp)
                            .background(PrimaryColor, CircleShape)
                            .testTag("send_chat_button")
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.Send,
                            contentDescription = "Send",
                            tint = Color.White,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ChatBubble(message: ChatMessage) {
    if (message.isSystemAlert) {
        // System Emergency Alert Box
        Surface(
            shape = RoundedCornerShape(12.dp),
            color = CriticalRedBg,
            border = androidx.compose.foundation.BorderStroke(1.dp, CriticalRed),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier.padding(12.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Warning,
                        contentDescription = null,
                        tint = CriticalRed,
                        modifier = Modifier.size(18.dp)
                    )
                    Text(
                        text = "SYSTEM ALERT",
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontWeight = FontWeight.Black,
                            color = CriticalRed,
                            letterSpacing = 1.sp
                        )
                    )
                    Spacer(modifier = Modifier.weight(1f))
                    Text(
                        text = message.time,
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontSize = 11.sp,
                            color = CriticalRed
                        )
                    )
                }
                Text(
                    text = message.message,
                    style = MaterialTheme.typography.bodyMedium.copy(
                        color = OnSurfaceColor,
                        fontWeight = FontWeight.SemiBold
                    )
                )
            }
        }
    } else {
        // Regular Message Bubble
        val isSelf = message.isSelf
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = if (isSelf) Arrangement.End else Arrangement.Start
        ) {
            Surface(
                shape = RoundedCornerShape(
                    topStart = 12.dp,
                    topEnd = 12.dp,
                    bottomStart = if (isSelf) 12.dp else 2.dp,
                    bottomEnd = if (isSelf) 2.dp else 12.dp
                ),
                color = if (isSelf) PrimaryFixed else SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(
                    1.dp,
                    if (isSelf) PrimaryFixedDim else OutlineVariantColor
                ),
                shadowElevation = 1.dp,
                modifier = Modifier.widthIn(max = 300.dp)
            ) {
                Column(
                    modifier = Modifier.padding(10.dp),
                    verticalArrangement = Arrangement.spacedBy(3.dp)
                ) {
                    if (!isSelf) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Text(
                                text = message.senderName,
                                style = MaterialTheme.typography.labelSmall.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = PrimaryColor
                                )
                            )
                            if (message.senderDindi.isNotBlank()) {
                                Surface(
                                    shape = RoundedCornerShape(4.dp),
                                    color = SurfaceContainerHigh
                                ) {
                                    Text(
                                        text = message.senderDindi,
                                        style = MaterialTheme.typography.labelSmall.copy(
                                            fontSize = 10.sp,
                                            color = OnSurfaceVariantColor
                                        ),
                                        modifier = Modifier.padding(horizontal = 4.dp, vertical = 1.dp)
                                    )
                                }
                            }
                        }
                    }

                    Text(
                        text = message.message,
                        style = MaterialTheme.typography.bodyMedium.copy(
                            color = OnSurfaceColor
                        )
                    )

                    Text(
                        text = message.time,
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontSize = 10.sp,
                            color = OnSurfaceVariantColor
                        ),
                        modifier = Modifier.align(Alignment.End)
                    )
                }
            }
        }
    }
}
