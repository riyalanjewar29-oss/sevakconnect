package com.example.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R
import com.example.ui.theme.*

@Composable
fun SplashScreen(
    onContinue: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(SurfaceColor)
    ) {
        // Background Hero Image with Pandharpur temple and sunrise
        Image(
            painter = painterResource(id = R.drawable.img_pandharpur_splash),
            contentDescription = "Pandharpur Wari Temple Background",
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )

        // Subtle gradient overlay for legibility
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color.White.copy(alpha = 0.85f),
                            Color.White.copy(alpha = 0.20f),
                            Color.White.copy(alpha = 0.90f)
                        ),
                        startY = 0f,
                        endY = 2400f
                    )
                )
        )

        // Top Branding & Content
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Spacer(modifier = Modifier.height(20.dp))

            // Logo & Title Block (Top-Center as shown in screenshot)
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(top = 24.dp)
            ) {
                // Circular Logo Container
                Box(
                    modifier = Modifier
                        .size(115.dp)
                        .clip(CircleShape)
                        .background(Color.White)
                        .border(2.dp, PrimaryContainerColor.copy(alpha = 0.4f), CircleShape)
                        .padding(10.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        painter = painterResource(id = R.drawable.ic_sevak_logo_1788005512622),
                        contentDescription = "SevakConnect Logo",
                        contentScale = ContentScale.Fit,
                        modifier = Modifier.fillMaxSize()
                    )
                }

                Spacer(modifier = Modifier.height(18.dp))

                // Brand Headline
                Text(
                    text = "SEVAKCONNECT",
                    style = MaterialTheme.typography.displayLarge.copy(
                        fontWeight = FontWeight.ExtraBold,
                        color = Color(0xFF1E293B),
                        letterSpacing = 1.sp
                    ),
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(6.dp))

                // Subtitle
                Text(
                    text = "Connected volunteers. Safer Wari.",
                    style = MaterialTheme.typography.bodyLarge.copy(
                        color = Color(0xFF334155),
                        fontWeight = FontWeight.Medium
                    ),
                    textAlign = TextAlign.Center
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // Bottom Section: Carousel dots, Marathi quote, and Get Started Button
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth()
            ) {
                // Carousel Indicator Dots
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(bottom = 16.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .width(28.dp)
                            .height(4.dp)
                            .clip(RoundedCornerShape(2.dp))
                            .background(PrimaryContainerColor)
                    )
                    Box(
                        modifier = Modifier
                            .width(16.dp)
                            .height(4.dp)
                            .clip(RoundedCornerShape(2.dp))
                            .background(Color(0xFFCBD5E1))
                    )
                    Box(
                        modifier = Modifier
                            .width(16.dp)
                            .height(4.dp)
                            .clip(RoundedCornerShape(2.dp))
                            .background(Color(0xFFCBD5E1))
                    )
                }

                // Marathi Devotional Motto
                Text(
                    text = "॥ सेवेकरी जोडले, वारी सुरक्षित. ॥",
                    style = MaterialTheme.typography.titleMedium.copy(
                        color = PrimaryColor,
                        fontWeight = FontWeight.Bold,
                        fontSize = 17.sp
                    ),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(bottom = 24.dp)
                )

                // Continue / Enter Button
                Button(
                    onClick = onContinue,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = PrimaryColor,
                        contentColor = OnPrimaryColor
                    ),
                    shape = RoundedCornerShape(999.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(54.dp)
                        .testTag("splash_continue_button")
                ) {
                    Text(
                        text = "Continue to SevakConnect",
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
}
