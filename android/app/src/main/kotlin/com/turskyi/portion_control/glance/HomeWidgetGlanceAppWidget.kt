package com.turskyi.portion_control.glance

import android.content.Context
import android.content.SharedPreferences
import android.content.res.Configuration
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
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.actionStartActivity
import java.util.Locale

class HomeWidgetGlanceAppWidget : GlanceAppWidget() {
    companion object {
        const val KEY_PORTION_CONTROL = "text_portion_control"
        const val KEY_WEIGHT = "text_weight"
        const val KEY_CONSUMED = "text_consumed"
        const val KEY_RECOMMENDATION = "pc_text_recommendation"
        const val KEY_LAST_UPDATED = "pc_text_last_updated"
        const val KEY_LOCALE = "pc_text_locale"
        const val KEY_IMAGE_PATH = "pc_image"

        // Create a localized context for resource lookups based on the
        // provided language code.
        fun getLocalizedContext(
            context: Context,
            languageCode: String
        ): Context {
            // Use forLanguageTag for standard BCP 47 tags (e.g., "en", "uk").
            val locale: Locale = Locale.forLanguageTag(
                languageCode,
            )
            Locale.setDefault(locale)
            val config = Configuration(
                context.resources.configuration,
            )
            config.setLocale(locale)

            // `createConfigurationContext` is safe and will NOT crash the
            // widget.
            // It is specifically designed to create a Context with overridden
            // resources.
            return context.createConfigurationContext(config)
        }
    }

    override val stateDefinition: GlanceStateDefinition<HomeWidgetGlanceState>
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val state: HomeWidgetGlanceState =
                currentState<HomeWidgetGlanceState>()
            GlanceContent(context, currentState = state)
        }
    }

    @Composable
    private fun GlanceContent(
        context: Context,
        currentState: HomeWidgetGlanceState
    ) {
        val widgetData: SharedPreferences = currentState.preferences

        // Get the locale from widget data and create localized context.
        val languageCode: String = widgetData.getString(
            KEY_LOCALE,
            "en",
        ) ?: "en"

        val localizedContext: Context = getLocalizedContext(
            context,
            languageCode,
        )

        val weight: String? = widgetData.getString(KEY_WEIGHT, null)
        val consumed: String? = widgetData.getString(
            KEY_CONSUMED,
            null,
        )

        val portionControl: String? = widgetData.getString(
            KEY_PORTION_CONTROL,
            null,
        )
        val recommendation: String? = widgetData.getString(
            KEY_RECOMMENDATION,
            null,
        )
        val lastUpdated: String? = widgetData.getString(
            KEY_LAST_UPDATED,
            null,
        )
        val imagePath: String? = widgetData.getString(
            KEY_IMAGE_PATH,
            null,
        )

        val defaultMessages: List<String> = listOf(
            localizedContext.getString(
                R.string.oops_no_meal_data_available,
            ),
            localizedContext.getString(
                R.string.looks_like_we_couldn_t_log_your_portion_this_time,
            ),
            localizedContext.getString(
                R.string.no_recommendation_trust_your_instincts_today,
            ),
            localizedContext.getString(
                R.string.data_s_taking_a_break_try_again_soon,
            ),
            localizedContext.getString(
                R.string.tracking_paused_try_again_later,
            ),
            localizedContext.getString(
                R.string.no_portions_logged_rest_day,
            ),
            localizedContext.getString(R.string.no_entry_available),
            localizedContext.getString(
                R.string.no_portion_info_right_now,
            )
        )

        // Check for hints.
        val weightValue: Double = weight?.toDoubleOrNull() ?: 0.0
        val consumedValue = consumed?.toDoubleOrNull() ?: 0.0
        val hintMessage: String? = when {
            weightValue == 0.0 -> localizedContext.getString(
                R.string.enter_weight_before_your_first_meal,
            )

            weightValue != 0.0 && consumedValue == 0.0 ->
                localizedContext.getString(
                    R.string.enter_food_weight,
                )

            else -> null
        }

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(16.dp)
                .background(ImageProvider(R.drawable.bg_widget_radial))
                .cornerRadius(12.dp)
                .clickable(
                    onClick = actionStartActivity<MainActivity>(context),
                ),
            contentAlignment = Alignment.Center
        ) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Vertical.Top,
                horizontalAlignment = Alignment.Horizontal.CenterHorizontally
            ) {
                // Weight.
                if (weightValue != 0.0) {
                    weight?.let { nnWeight: String ->
                        Text(
                            text = localizedContext.getString(
                                R.string.weight_kg,
                                nnWeight
                            ),
                            style = TextStyle(
                                fontSize = 24.sp,
                                textAlign = TextAlign.Center,
                                fontWeight = FontWeight.Bold
                            )
                        )
                    }
                }

                // Consumed.
                if (consumedValue != 0.0) {
                    consumed?.let {
                        Text(
                            text = localizedContext.getString(
                                R.string.consumed_g,
                                it,
                            ),
                            style = TextStyle(
                                fontSize = 18.sp,
                                textAlign = TextAlign.Center
                            )
                        )
                    }
                }

                // Portion Control.
                if (!portionControl.isNullOrEmpty()) {
                    Text(
                        text = localizedContext.getString(
                            R.string.limit_g,
                            portionControl
                        ),
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
                    val bitmap: Bitmap? = BitmapFactory.decodeFile(
                        it,
                    )
                    bitmap?.let { bmp: Bitmap ->
                        Image(
                            provider = ImageProvider(bitmap = bmp),
                            contentDescription = localizedContext.getString(
                                R.string.chart,
                            ),
                            modifier = GlanceModifier
                                .fillMaxWidth()
                        )
                    }
                }
            }
        }
    }
}
