import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/vault_provider.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vault = ref.watch(vaultProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cofre',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () {
              // TODO: Importar mídia via photo_manager
            },
          ),
        ],
      ),
      body: vault.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vault.mediaList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_album_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.15),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Seu cofre está vazio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque em + para importar fotos e vídeos',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: vault.mediaList.length,
                  itemBuilder: (context, index) {
                    final item = vault.mediaList[index];
                    return Container(
                      color: colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: Colors.black26,
                            ),
                          ),
                          if (item.favorite)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Icon(
                                Icons.favorite,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                          if (item.mediaType == 'video')
                            const Positioned(
                              bottom: 4,
                              right: 4,
                              child: Icon(
                                Icons.play_circle_fill,
                                size: 20,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Importar mídia
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
