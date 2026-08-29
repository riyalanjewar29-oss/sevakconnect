package com.example.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.CheckCircle
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R
import com.example.data.model.UserRole
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.theme.*

data class AdminDepartmentOption(
    val emoji: String,
    val title: String,
    val marathiTitle: String,
    val description: String
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RoleSetupScreen(
    repository: SevakRepository,
    onRoleConfirmed: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isOnline by repository.isOnline.collectAsState()
    val userProfile by repository.userProfile.collectAsState()

    var selectedRole by remember { mutableStateOf(UserRole.VOLUNTEER) }
    var selectedDepartment by remember { mutableStateOf("👮 Police / Security") }
    var showDeptDialog by remember { mutableStateOf(false) }

    var selectedAffiliation by remember { mutableStateOf("Varkari Group") }
    var otherOrganizationName by remember { mutableStateOf("") }
    var isDropdownExpanded by remember { mutableStateOf(false) }

    val adminDepartments = listOf(
        AdminDepartmentOption(
            emoji = "👮",
            title = "Police / Security",
            marathiTitle = "पोलीस / सुरक्षा विभाग",
            description = "Bandobast, crowd perimeter control, route security & law order"
        ),
        AdminDepartmentOption(
            emoji = "🏥",
            title = "Medical / Health",
            marathiTitle = "वैद्यकीय / आरोग्य पथक",
            description = "First-aid triage, doctor camps, emergency ambulances & heatstroke care"
        ),
        AdminDepartmentOption(
            emoji = "👥",
            title = "Crowd & Ghat Safety",
            marathiTitle = "गर्दी व चंद्रभागा घाट सुरक्षा",
            description = "River barricading, ghat diver squads, flow management & safe transit"
        ),
        AdminDepartmentOption(
            emoji = "🛕",
            title = "Darshan Operations",
            marathiTitle = "दर्शन व्यवस्थापन कक्ष",
            description = "Mukh darshan, Charansparsh queues, token counters & sanctum flow"
        ),
        AdminDepartmentOption(
            emoji = "🚨",
            title = "Emergency Command",
            marathiTitle = "आपत्कालीन नियंत्रण कक्ष",
            description = "Disaster cell, Quick Response Team (QRT) & central emergency dispatch"
        ),
        AdminDepartmentOption(
            emoji = "🏛️",
            title = "District Administration",
            marathiTitle = "जिल्हा प्रशासन / नगरपालिका",
            description = "Solapur collectorate, municipal sanitation, drinking water & logistics"
        )
    )

    val volunteerAffiliationOptions = listOf(
        "Varkari Group",
        "Seva Samiti Foundation",
        "Pilgrim Medical Corps",
        "Traffic Assistance Squad",
        "Sant Tukaram Seva Dal",
        "Other"
    )

    val adminAffiliationOptions = listOf(
        "Solapur District Police",
        "Pandharpur Municipal Corporation",
        "District Health Office (DHO)",
        "Shree Vitthal Temple Trust",
        "Disaster Management Authority",
        "Other"
    )

    val currentAffiliationOptions = if (selectedRole == UserRole.ADMINISTRATIVE) {
        adminAffiliationOptions
    } else {
        volunteerAffiliationOptions
    }

    // Modal Sheet / Dialog for Administrative Department Selection
    if (showDeptDialog) {
        ModalBottomSheet(
            onDismissRequest = { showDeptDialog = false },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = Color.White
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 12.dp)
                    .navigationBarsPadding(),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                // Modal Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text(
                            text = "Select Administrative Wing",
                            style = MaterialTheme.typography.titleLarge.copy(
                                fontWeight = FontWeight.Bold,
                                color = OnSurfaceColor
                            )
                        )
                        Text(
                            text = "प्रशासकीय विभाग निवडा",
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = PrimaryColor,
                                fontWeight = FontWeight.SemiBold
                            )
                        )
                    }
                    IconButton(onClick = { showDeptDialog = false }) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "Close")
                    }
                }

                HorizontalDivider(color = SurfaceVariantColor)

                // Departments list
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .verticalScroll(rememberScrollState()),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    adminDepartments.forEach { dept ->
                        val isDeptSelected = selectedDepartment == "${dept.emoji} ${dept.title}"
                        Surface(
                            shape = RoundedCornerShape(14.dp),
                            color = if (isDeptSelected) PrimaryContainerColor.copy(alpha = 0.25f) else SurfaceContainerLowest,
                            border = androidx.compose.foundation.BorderStroke(
                                width = if (isDeptSelected) 2.dp else 1.dp,
                                color = if (isDeptSelected) PrimaryColor else OutlineVariantColor
                            ),
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    selectedDepartment = "${dept.emoji} ${dept.title}"
                                    showDeptDialog = false
                                }
                                .testTag("admin_dept_${dept.title.lowercase().replace(" ", "_")}")
                        ) {
                            Row(
                                modifier = Modifier.padding(16.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(14.dp)
                            ) {
                                Text(
                                    text = dept.emoji,
                                    fontSize = 28.sp
                                )
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = "${dept.emoji} ${dept.title}",
                                        style = MaterialTheme.typography.titleMedium.copy(
                                            fontWeight = FontWeight.Bold,
                                            color = OnSurfaceColor
                                        )
                                    )
                                    Text(
                                        text = dept.marathiTitle,
                                        style = MaterialTheme.typography.labelSmall.copy(
                                            color = PrimaryColor,
                                            fontWeight = FontWeight.SemiBold
                                        )
                                    )
                                    Spacer(modifier = Modifier.height(2.dp))
                                    Text(
                                        text = dept.description,
                                        style = MaterialTheme.typography.bodySmall.copy(
                                            color = OnSurfaceVariantColor,
                                            fontSize = 12.sp
                                        )
                                    )
                                }
                                RadioButton(
                                    selected = isDeptSelected,
                                    onClick = {
                                        selectedDepartment = "${dept.emoji} ${dept.title}"
                                        showDeptDialog = false
                                    },
                                    colors = RadioButtonDefaults.colors(selectedColor = PrimaryColor)
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))
            }
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(SurfaceColor)
    ) {
        // Top App Bar with Logo Centered
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
                // Left spacing
                Box(modifier = Modifier.size(40.dp))

                // Centered Logo & Brand Name
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(Color.White)
                            .border(1.dp, PrimaryContainerColor.copy(alpha = 0.5f), CircleShape)
                            .padding(4.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Image(
                            painter = painterResource(id = R.drawable.ic_sevak_logo_1788005512622),
                            contentDescription = "SevakConnect Logo",
                            modifier = Modifier
                                .fillMaxSize()
                                .testTag("setup_logo")
                        )
                    }
                    Text(
                        text = "SEVAKCONNECT",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Black,
                            color = OnSurfaceColor,
                            letterSpacing = 0.5.sp
                        )
                    )
                }

                IconButton(
                    onClick = { repository.toggleOnlineStatus() },
                    modifier = Modifier.size(40.dp)
                ) {
                    Icon(
                        painter = painterResource(
                            id = if (isOnline) android.R.drawable.ic_menu_rotate else android.R.drawable.stat_sys_warning
                        ),
                        contentDescription = "Connection Status",
                        tint = if (isOnline) PrimaryColor else WarningYellow
                    )
                }
            }
        }

        OfflineBanner(isOnline = isOnline)

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Header Text
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 8.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Setup Your Role",
                    style = MaterialTheme.typography.displayLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = OnSurfaceColor,
                        fontSize = 28.sp
                    ),
                    textAlign = TextAlign.Center
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "Select how you will serve in the Pandharpur Wari.",
                    style = MaterialTheme.typography.bodyMedium.copy(
                        color = OnSurfaceVariantColor
                    ),
                    textAlign = TextAlign.Center
                )
            }

            // Volunteer Role Card
            val isVolunteer = selectedRole == UserRole.VOLUNTEER
            Surface(
                shape = RoundedCornerShape(16.dp),
                color = if (isVolunteer) SurfaceContainerHigh else SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(
                    width = if (isVolunteer) 2.dp else 1.dp,
                    color = if (isVolunteer) PrimaryColor else OutlineVariantColor
                ),
                shadowElevation = if (isVolunteer) 3.dp else 1.dp,
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable {
                        selectedRole = UserRole.VOLUNTEER
                        selectedAffiliation = "Varkari Group"
                    }
                    .testTag("role_volunteer_card")
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(60.dp)
                            .clip(CircleShape)
                            .background(PrimaryContainerColor),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.VolunteerActivism,
                            contentDescription = "Volunteer",
                            tint = OnPrimaryContainerColor,
                            modifier = Modifier.size(30.dp)
                        )
                    }
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "Volunteer (वारकरी सेवक)",
                        style = MaterialTheme.typography.titleLarge.copy(
                            fontWeight = FontWeight.Bold,
                            color = OnSurfaceColor
                        )
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "General seva, crowd guidance, water & pilgrim aid",
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = OnSurfaceVariantColor
                        ),
                        textAlign = TextAlign.Center
                    )
                }
            }

            // Administrative Role Card (Replaced Dindi Leader)
            val isAdministrative = selectedRole == UserRole.ADMINISTRATIVE
            Surface(
                shape = RoundedCornerShape(16.dp),
                color = if (isAdministrative) SurfaceContainerHigh else SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(
                    width = if (isAdministrative) 2.dp else 1.dp,
                    color = if (isAdministrative) SecondaryColor else OutlineVariantColor
                ),
                shadowElevation = if (isAdministrative) 3.dp else 1.dp,
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable {
                        selectedRole = UserRole.ADMINISTRATIVE
                        selectedAffiliation = "Solapur District Police"
                        showDeptDialog = true
                    }
                    .testTag("role_administrative_card")
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(60.dp)
                            .clip(CircleShape)
                            .background(SecondaryContainerColor),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.AdminPanelSettings,
                            contentDescription = "Administrative",
                            tint = OnSecondaryContainerColor,
                            modifier = Modifier.size(30.dp)
                        )
                    }
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "Administrative (प्रशासकीय अधिकारी)",
                        style = MaterialTheme.typography.titleLarge.copy(
                            fontWeight = FontWeight.Bold,
                            color = OnSurfaceColor
                        )
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Police, Health, Ghat Safety, Darshan & Emergency Command",
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = OnSurfaceVariantColor
                        ),
                        textAlign = TextAlign.Center
                    )

                    // Active Selected Department Pill
                    if (isAdministrative) {
                        Spacer(modifier = Modifier.height(14.dp))
                        Surface(
                            shape = RoundedCornerShape(10.dp),
                            color = SecondaryContainerColor.copy(alpha = 0.6f),
                            border = androidx.compose.foundation.BorderStroke(1.dp, SecondaryColor.copy(alpha = 0.5f)),
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { showDeptDialog = true }
                                .testTag("change_admin_dept_button")
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Column {
                                    Text(
                                        text = "SELECTED DEPARTMENT",
                                        style = MaterialTheme.typography.labelSmall.copy(
                                            color = OnSecondaryContainerColor,
                                            fontWeight = FontWeight.Bold,
                                            fontSize = 10.sp
                                        )
                                    )
                                    Text(
                                        text = selectedDepartment,
                                        style = MaterialTheme.typography.titleSmall.copy(
                                            color = OnSecondaryContainerColor,
                                            fontWeight = FontWeight.Bold
                                        )
                                    )
                                }
                                TextButton(onClick = { showDeptDialog = true }) {
                                    Text(
                                        text = "Change",
                                        style = MaterialTheme.typography.labelMedium.copy(
                                            fontWeight = FontWeight.Bold,
                                            color = SecondaryColor
                                        )
                                    )
                                }
                            }
                        }
                    }
                }
            }

            // Affiliation & Unit Card
            Surface(
                shape = RoundedCornerShape(16.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                shadowElevation = 1.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    Text(
                        text = if (selectedRole == UserRole.ADMINISTRATIVE) "Department / Unit Division" else "Affiliation / Dindi",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = OnSurfaceColor
                        )
                    )
                    HorizontalDivider(color = SurfaceVariantColor)

                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Text(
                            text = if (selectedRole == UserRole.ADMINISTRATIVE) "Select Organization / Division" else "Select Dindi / NGO",
                            style = MaterialTheme.typography.labelMedium.copy(
                                color = OnSurfaceColor,
                                fontWeight = FontWeight.SemiBold
                            )
                        )

                        ExposedDropdownMenuBox(
                            expanded = isDropdownExpanded,
                            onExpandedChange = { isDropdownExpanded = !isDropdownExpanded },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            OutlinedTextField(
                                value = selectedAffiliation,
                                onValueChange = {},
                                readOnly = true,
                                trailingIcon = {
                                    ExposedDropdownMenuDefaults.TrailingIcon(expanded = isDropdownExpanded)
                                },
                                shape = RoundedCornerShape(10.dp),
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = PrimaryColor,
                                    unfocusedBorderColor = OutlineColor
                                ),
                                modifier = Modifier
                                    .menuAnchor()
                                    .fillMaxWidth()
                                    .testTag("affiliation_dropdown")
                            )

                            ExposedDropdownMenu(
                                expanded = isDropdownExpanded,
                                onDismissRequest = { isDropdownExpanded = false }
                            ) {
                                currentAffiliationOptions.forEach { option ->
                                    DropdownMenuItem(
                                        text = { Text(option) },
                                        onClick = {
                                            selectedAffiliation = option
                                            isDropdownExpanded = false
                                        }
                                    )
                                }
                            }
                        }
                    }

                    // Other organization input if "Other" chosen
                    AnimatedVisibility(visible = selectedAffiliation == "Other") {
                        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                            Text(
                                text = "Enter Specific Unit / Org Name",
                                style = MaterialTheme.typography.labelMedium.copy(
                                    color = OnSurfaceColor,
                                    fontWeight = FontWeight.SemiBold
                                )
                            )
                            OutlinedTextField(
                                value = otherOrganizationName,
                                onValueChange = { otherOrganizationName = it },
                                placeholder = { Text("Specify department, station or group") },
                                shape = RoundedCornerShape(10.dp),
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = PrimaryColor,
                                    unfocusedBorderColor = OutlineColor
                                ),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .testTag("other_org_input")
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Continue Button
            Button(
                onClick = {
                    val finalAffiliation = if (selectedAffiliation == "Other" && otherOrganizationName.isNotBlank()) {
                        otherOrganizationName
                    } else {
                        selectedAffiliation
                    }
                    val dept = if (selectedRole == UserRole.ADMINISTRATIVE) selectedDepartment else ""
                    repository.updateUserRole(selectedRole, finalAffiliation, dept)
                    onRoleConfirmed()
                },
                colors = ButtonDefaults.buttonColors(
                    containerColor = PrimaryColor,
                    contentColor = OnPrimaryColor
                ),
                shape = RoundedCornerShape(999.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(54.dp)
                    .navigationBarsPadding()
                    .testTag("setup_continue_button")
            ) {
                Text(
                    text = "Continue to Dashboard",
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp
                    )
                )
                Spacer(modifier = Modifier.width(8.dp))
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}
