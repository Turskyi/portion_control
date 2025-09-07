package com.turskyi.portion_control.glance

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.color.ColorProvider
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import com.turskyi.portion_control.MainActivity
import com.turskyi.portion_control.R
import es.antonborri.home_widget.actionStartActivity

class HomeWidgetGlanceAppWidget : GlanceAppWidget() {

    override val stateDefinition: GlanceStateDefinition<*>?
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context, currentState())
        }
    }

    @Composable
    private fun GlanceContent(
        context: Context,
        currentState: HomeWidgetGlanceState
    ) {
        val widgetData = currentState.preferences

        val weight: String? = widgetData.getString("text_weight", null)
        val consumed: String? = widgetData.getString("text_consumed", null)
        val portionControl: String? =
            widgetData.getString("portion_control", null)
        val recommendation: String? =
            widgetData.getString("text_recommendation", null)
        val lastUpdated: String? =
            widgetData.getString("text_last_updated", null)
        val imagePath: String? = widgetData.getString("image", null)

        val defaultMessages = listOf(
            "🍽️ Oops! No meal data available.",
            "🤷 Looks like we couldn’t log your portion this time.",
            "🥗 No recommendation? Trust your instincts today!",
            "📊 Data’s taking a break - try again soon!",
            "🚀 Tracking paused, try again later!",
            "😴 No portions logged - rest day?",
            "❌ No entry available",
            "🤔 No portion info right now"
        )

        // Check for hints.
        val weightValue = weight?.toDoubleOrNull() ?: 0.0
        val consumedValue = consumed?.toDoubleOrNull() ?: 0.0
        val hintMessage: String? = when {
            weightValue == 0.0 -> "👉 Enter weight before your first meal."
            weightValue != 0.0 && consumedValue == 0.0 -> "👉 Enter food weight."
            else -> null
        }

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(16.dp)
                .background(ImageProvider(R.drawable.bg_widget_radial))
                .cornerRadius(12.dp)
                .clickable(onClick = actionStartActivity<MainActivity>(context)),
            contentAlignment = Alignment.Center
        ) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Vertical.Top,
                horizontalAlignment = Alignment.Horizontal.CenterHorizontally
            ) {
                // Weight.
                if (weightValue != 0.0) {
                    Text(
                        text = "Weight: $weight kg",
                        style = TextStyle(
                            fontSize = 24.sp,
                            textAlign = TextAlign.Center,
                            fontWeight = FontWeight.Bold
                        )
                    )
                }

                // Consumed.
                if (consumedValue != 0.0) {
                    Text(
                        text = "Consumed: $consumed g",
                        style = TextStyle(
                            fontSize = 18.sp,
                            textAlign = TextAlign.Center
                        )
                    )
                }

                // Portion Control.
                if (!portionControl.isNullOrEmpty()) {
                    Text(
                        text = "Limit: $portionControl g",
                        style = TextStyle(
                            fontSize = 16.sp,
                            textAlign = TextAlign.Center
                        )
                    )
                }

                // Recommendation or hint.
                Text(
                    text = hintMessage ?: (recommendation
                        ?: "").ifEmpty { defaultMessages.random() },
                    style = TextStyle(
                        fontSize = 16.sp,
                        textAlign = TextAlign.Center,
                        color = ColorProvider(
                            day = Color(0xFFa9a9a9),
                            night = Color(0xFFa9a9a9)
                        ),
                        fontWeight = FontWeight.Bold
                    ),
                    modifier = GlanceModifier.padding(top = 8.dp)
                )

                // Last Updated.
                if (!lastUpdated.isNullOrEmpty()) {
                    Text(
                        text = lastUpdated,
                        style = TextStyle(
                            fontSize = 14.sp,
                            textAlign = TextAlign.Center
                        )
                    )
                }

                // Chart image.
                imagePath?.let {
                    val bitmap: Bitmap? = BitmapFactory.decodeFile(it)
                    bitmap?.let { bmp ->
                        Image(
                            provider = ImageProvider(bmp),
                            contentDescription = "Chart",
                            modifier = GlanceModifier
                                .fillMaxWidth()
                                .padding(top = 6.dp)
                        )
                    }
                }
            }
        }
    }
}

