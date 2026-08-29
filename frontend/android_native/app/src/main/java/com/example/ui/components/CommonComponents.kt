package com.example.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R
import com.example.ui.navigation.BottomTab
import com.example.ui.theme.*

@Composable
fun SevakTopAppBar(
    title: String = "SevakConnect",
    showBackButton: Boolean = false,
    showAvatar: Boolean = true,
    isOnline: Boolean = true,
    onBackClick: () -> Unit = {},
    onAvatarClick: () -> Unit = {},
    onOfflineToggleClick: () -> Unit = {},
    titleColor: Color = PrimaryColor,
    modifier: Modifier = Modifier
) {
    Surface(
        color = SurfaceContainerLowest,
        shadowElevation = 1.dp,
        modifier = modifier.fillMaxWidth()
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
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                if (showBackButton) {
                    IconButton(
                        onClick = onBackClick,
                        modifier = Modifier
                            .size(40.dp)
                            .testTag("top_back_button")
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Back",
                            tint = OnSurfaceColor
                        )
                    }
                } else if (showAvatar) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(Color.White)
                            .border(1.5.dp, PrimaryColor.copy(alpha = 0.4f), CircleShape)
                            .clickable { onAvatarClick() }
                            .padding(2.dp)
                            .testTag("top_avatar_button"),
                        contentAlignment = Alignment.Center
                    ) {
                        Image(
                            painter = painterResource(id = R.drawable.ic_sevak_logo_1788005512622),
                            contentDescription = "SevakConnect",
                            contentScale = ContentScale.Fit,
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                }

                Text(
                    text = title,
                    style = MaterialTheme.typography.headlineMedium.copy(
                        fontWeight = FontWeight.Bold,
                        color = titleColor
                    ),
                    modifier = Modifier.testTag("app_bar_title")
                )
            }

            IconButton(
                onClick = onOfflineToggleClick,
                modifier = Modifier
                    .size(40.dp)
                    .testTag("offline_toggle_button")
            ) {
                Icon(
                    painter = painterResource(
                        id = if (isOnline) android.R.drawable.ic_menu_rotate else android.R.drawable.stat_sys_warning
                    ),
                    contentDescription = if (isOnline) "Online Mode" else "Offline Mode",
                    tint = if (isOnline) PrimaryColor else WarningYellow
                )
            }
        }
    }
}

@Composable
fun OfflineBanner(
    isOnline: Boolean,
    modifier: Modifier = Modifier,
    customText: String? = null
) {
    AnimatedVisibility(
        visible = !isOnline,
        enter = expandVertically(),
        exit = shrinkVertically()
    ) {
        Row(
            modifier = modifier
                .fillMaxWidth()
                .background(WarningYellow)
                .padding(vertical = 6.dp, horizontal = 16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = Icons.Default.CloudOff,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = customText ?: "Working Offline - Data sync pending",
                style = MaterialTheme.typography.labelMedium.copy(
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            )
        }
    }
}

@Composable
fun SevakBottomNavBar(
    currentTab: BottomTab,
    onTabSelected: (BottomTab) -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        color = SurfaceContainerLowest,
        shadowElevation = 8.dp,
        modifier = modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .navigationBarsPadding()
                .padding(vertical = 8.dp, horizontal = 12.dp),
            horizontalArrangement = Arrangement.SpaceAround,
            verticalAlignment = Alignment.CenterVertically
        ) {
            BottomTab.values().forEach { tab ->
                val isSelected = currentTab == tab
                
                if (isSelected) {
                    // Active pill button
                    Surface(
                        shape = RoundedCornerShape(999.dp),
                        color = SecondaryContainerColor,
                        modifier = Modifier
                            .clickable { onTabSelected(tab) }
                            .testTag("nav_tab_${tab.name.lowercase()}")
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center,
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
                        ) {
                            Icon(
                                imageVector = when (tab) {
                                    BottomTab.HOME -> Icons.Default.Home
                                    BottomTab.CHAT -> Icons.Default.ChatBubble
                                    BottomTab.TASKS -> Icons.Default.Assignment
                                    BottomTab.MAP -> Icons.Default.Map
                                },
                                contentDescription = tab.title,
                                tint = OnSecondaryContainerColor,
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = tab.title,
                                style = MaterialTheme.typography.labelSmall.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = OnSecondaryContainerColor
                                )
                            )
                        }
                    }
                } else {
                    // Inactive button
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier
                            .clickable { onTabSelected(tab) }
                            .padding(horizontal = 12.dp, vertical = 4.dp)
                            .testTag("nav_tab_${tab.name.lowercase()}")
                    ) {
                        Icon(
                            imageVector = when (tab) {
                                BottomTab.HOME -> Icons.Outlined.Home
                                BottomTab.CHAT -> Icons.Outlined.ChatBubbleOutline
                                BottomTab.TASKS -> Icons.Outlined.Assignment
                                BottomTab.MAP -> Icons.Outlined.Map
                            },
                            contentDescription = tab.title,
                            tint = OnSurfaceVariantColor,
                            modifier = Modifier.size(22.dp)
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = tab.title,
                            style = MaterialTheme.typography.labelSmall.copy(
                                color = OnSurfaceVariantColor,
                                fontSize = 11.sp
                            )
                        )
                    }
                }
            }
        }
    }
}
