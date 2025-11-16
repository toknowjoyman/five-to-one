import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_settings.dart';
import '../../theme/app_theme.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              // Theme Mode Section
              _SectionHeader('Theme Mode'),
              _ThemeModeSelector(),
              const Divider(),

              // Color Palette Section
              _SectionHeader('Color Palette'),
              _ColorPaletteGrid(),
              const Divider(),

              // Background Section
              _SectionHeader('Background'),
              _BackgroundTypeSelector(),
              if (themeProvider.backgroundType == BackgroundType.solidColor)
                _ColorPickerTile(
                  title: 'Background Color',
                  color: _hexToColor(themeProvider.backgroundValue),
                  onColorChanged: (color) {
                    themeProvider.setBackground(
                      value: _colorToHex(color),
                    );
                  },
                ),
              if (themeProvider.backgroundType == BackgroundType.gradient)
                _GradientPicker(),
              _OpacitySlider(),
              const Divider(),

              // Accent Color
              _SectionHeader('Accent Color'),
              _ColorPickerTile(
                title: 'Primary Accent',
                color: themeProvider.accentColor,
                onColorChanged: (color) {
                  themeProvider.setAccentColor(color);
                  themeProvider.triggerHaptic();
                },
              ),
              const Divider(),

              // Font Settings
              _SectionHeader('Font'),
              _FontScaleSlider(),
              _FontFamilySelector(),
              const Divider(),

              // UI Preferences
              _SectionHeader('UI Preferences'),
              SwitchListTile(
                title: const Text('Compact Mode'),
                subtitle: const Text('Reduce padding and spacing'),
                value: themeProvider.compactMode,
                onChanged: (value) => themeProvider.setCompactMode(value),
              ),
              SwitchListTile(
                title: const Text('Show Completed Tasks'),
                subtitle: const Text('Display completed tasks in lists'),
                value: themeProvider.showCompletedTasks,
                onChanged: (value) => themeProvider.setShowCompletedTasks(value),
              ),
              SwitchListTile(
                title: const Text('Animations'),
                subtitle: const Text('Enable smooth animations'),
                value: themeProvider.enableAnimations,
                onChanged: (value) => themeProvider.setEnableAnimations(value),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            label: Text('Light'),
            icon: Icon(Icons.light_mode),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text('Dark'),
            icon: Icon(Icons.dark_mode),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            label: Text('Auto'),
            icon: Icon(Icons.brightness_auto),
          ),
        ],
        selected: {themeProvider.themeMode},
        onSelectionChanged: (Set<ThemeMode> selection) {
          themeProvider.setThemeMode(selection.first);
          themeProvider.triggerHaptic();
        },
      ),
    );
  }
}

class _ColorPaletteGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: ColorPalette.allPalettes.length,
        itemBuilder: (context, index) {
          final palette = ColorPalette.allPalettes[index];
          final isSelected = themeProvider.accentColor.value == palette.primary.value;

          return GestureDetector(
            onTap: () {
              themeProvider.applyColorPalette(palette);
              themeProvider.triggerHaptic();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: palette.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(9),
                              topRight: Radius.circular(9),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: palette.secondary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(9),
                              bottomRight: Radius.circular(9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BackgroundTypeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Solid'),
            selected: themeProvider.backgroundType == BackgroundType.solidColor,
            onSelected: (selected) {
              if (selected) {
                themeProvider.setBackground(type: BackgroundType.solidColor);
              }
            },
          ),
          ChoiceChip(
            label: const Text('Gradient'),
            selected: themeProvider.backgroundType == BackgroundType.gradient,
            onSelected: (selected) {
              if (selected) {
                themeProvider.setBackground(type: BackgroundType.gradient);
              }
            },
          ),
          ChoiceChip(
            label: const Text('Pattern'),
            selected: themeProvider.backgroundType == BackgroundType.pattern,
            onSelected: (selected) {
              if (selected) {
                themeProvider.setBackground(type: BackgroundType.pattern);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ColorPickerTile extends StatelessWidget {
  final String title;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const _ColorPickerTile({
    required this.title,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24, width: 2),
          ),
        ),
      ),
      onTap: () => _showColorPicker(context),
    );
  }

  void _showColorPicker(BuildContext context) {
    final basicColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: basicColors.length,
            itemBuilder: (context, index) {
              final pickerColor = basicColors[index];
              return GestureDetector(
                onTap: () {
                  onColorChanged(pickerColor);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: pickerColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color == pickerColor ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _GradientPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('Gradient Editor'),
      subtitle: Text('Coming soon'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

class _OpacitySlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return ListTile(
      title: const Text('Background Opacity'),
      subtitle: Slider(
        value: themeProvider.backgroundOpacity,
        min: 0.3,
        max: 1.0,
        divisions: 7,
        label: '${(themeProvider.backgroundOpacity * 100).round()}%',
        onChanged: (value) {
          themeProvider.setBackground(opacity: value);
        },
      ),
    );
  }
}

class _FontScaleSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return ListTile(
      title: const Text('Font Size'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: themeProvider.fontScale,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            label: '${(themeProvider.fontScale * 100).round()}%',
            onChanged: (value) {
              themeProvider.setFontScale(value);
            },
          ),
          Text(
            'Sample text at current size',
            style: TextStyle(fontSize: 14 * themeProvider.fontScale),
          ),
        ],
      ),
    );
  }
}

class _FontFamilySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final fonts = ['System', 'Roboto', 'Montserrat', 'Open Sans', 'Lato'];

    return ListTile(
      title: const Text('Font Family'),
      subtitle: DropdownButton<String>(
        value: themeProvider.fontFamily,
        isExpanded: true,
        items: fonts.map((font) {
          return DropdownMenuItem(
            value: font,
            child: Text(font, style: TextStyle(fontFamily: font == 'System' ? null : font)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            themeProvider.setFontFamily(value);
          }
        },
      ),
    );
  }
}
