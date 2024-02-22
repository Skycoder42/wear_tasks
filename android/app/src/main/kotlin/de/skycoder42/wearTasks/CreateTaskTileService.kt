package de.skycoder42.wearTasks

import androidx.wear.protolayout.ColorBuilders.ColorProp
import androidx.wear.protolayout.LayoutElementBuilders.LayoutElement
import androidx.wear.protolayout.ModifiersBuilders.Clickable
import androidx.wear.protolayout.TimelineBuilders.Timeline
import androidx.wear.protolayout.material.ChipColors
import androidx.wear.protolayout.material.Colors
import androidx.wear.protolayout.material.CompactChip
import androidx.wear.protolayout.material.Text
import androidx.wear.protolayout.material.Typography
import androidx.wear.protolayout.material.layouts.PrimaryLayout
import androidx.wear.tiles.RequestBuilders
import androidx.wear.tiles.TileBuilders
import androidx.wear.tiles.TileService
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture

class CreateTaskTileService : TileService() {
    override fun onTileRequest(requestParams: RequestBuilders.TileRequest): ListenableFuture<TileBuilders.Tile> =
        Futures.immediateFuture(
            TileBuilders.Tile.Builder()
                .setTileTimeline(Timeline.fromLayoutElement(tileLayout(requestParams)))
                .build()
        )

    private fun tileLayout(requestParams: RequestBuilders.TileRequest): LayoutElement =
        PrimaryLayout.Builder(requestParams.deviceConfiguration)
            .setPrimaryLabelTextContent(
                Text.Builder(this, "Create new Task")
                    .setTypography(Typography.TYPOGRAPHY_CAPTION1)
                    .setColor(ColorProp.Builder(theme().onSurface).build())
                    .build()
            )
            .setContent(
                Text.Builder(this, "Create new Task")
                    .setTypography(Typography.TYPOGRAPHY_TITLE2)
                    .setColor(ColorProp.Builder(theme().onSurface).build())
                    .build()
            )
            .setPrimaryChipContent(
                CompactChip.Builder(
                    this,
                    "Create",
                    generateClickable(),
                    requestParams.deviceConfiguration
                )
                    // .setIconContent("icon_add")
                    .setChipColors(ChipColors.primaryChipColors(theme()))
                    .build()
            )
            .build()

    private fun generateClickable(): Clickable = Clickable.Builder()
        .build()

    private fun theme(): Colors = Colors(
        0xFF673ab7.toInt(),
        0xFFFFFFFF.toInt(),
        0xFF000000.toInt(),
        0xFFFFFFFF.toInt(),
    )
}