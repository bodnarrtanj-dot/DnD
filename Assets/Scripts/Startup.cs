using UnityEngine;

/// <summary>
/// Автоматичне налаштування сцени при запуску
/// Виправляє проблему з синім екраном
/// </summary>
public class Startup : MonoBehaviour
{
    [Header("Налаштування стартової сцени")]
    [SerializeField] private Camera mainCamera;
    [SerializeField] private Transform playerTransform;
    [SerializeField] private SpriteRenderer mapRenderer;
    [SerializeField] private WorldMap worldMap;
    
    private void Start()
    {
        // 1. Налаштовуємо камеру
        SetupCamera();
        
        // 2. Налаштовуємо гравця
        SetupPlayer();
        
        // 3. Налаштовуємо карту
        SetupMap();
        
        // 4. Налаштовуємо WorldMap
        SetupWorldMap();
        
        Debug.Log("Сцена налаштована! Гра готова до запуску.");
    }
    
    private void SetupCamera()
    {
        if (mainCamera == null)
        {
            mainCamera = Camera.main;
            if (mainCamera == null)
            {
                Debug.LogError("Main Camera не знайдена! Створюю нову...");
                GameObject cameraObj = new GameObject("Main Camera");
                mainCamera = cameraObj.AddComponent<Camera>();
                mainCamera.tag = "MainCamera";
            }
        }
        
        // Встановлюємо Orthographic projection
        mainCamera.orthographic = true;
        mainCamera.orthographicSize = 5f;
        mainCamera.nearClipPlane = 0.3f;
        mainCamera.farClipPlane = 1000f;
        mainCamera.clearFlags = CameraClearFlags.SolidColor;
        mainCamera.backgroundColor = new Color(0.1f, 0.1f, 0.1f); // Темно-сірий фон
        
        // Додаємо CameraController, якщо його немає
        if (mainCamera.GetComponent<CameraController>() == null)
        {
            mainCamera.gameObject.AddComponent<CameraController>();
        }
    }
    
    private void SetupPlayer()
    {
        if (playerTransform == null)
        {
            // Шукаємо гравця за тегом
            playerTransform = GameObject.FindGameObjectWithTag("Player").transform;
            
            if (playerTransform == null)
            {
                Debug.LogError("Player не знайдений! Створюю нового...");
                GameObject playerObj = new GameObject("Player");
                playerObj.tag = "Player";
                playerTransform = playerObj.transform;
                
                // Додаємо SpriteRenderer
                SpriteRenderer renderer = playerObj.AddComponent<SpriteRenderer>();
                renderer.sprite = CreateColoredSprite(Color.green);
                renderer.size = new Vector2(1, 1);
                
                // Додаємо PlayerController
                playerObj.AddComponent<PlayerController>();
            }
        }
        
        // Встановлюємо позицію гравця в центр
        playerTransform.position = new Vector3(0, 0, 0);
    }
    
    private void SetupMap()
    {
        if (mapRenderer == null)
        {
            // Шукаємо карту за ім'ям
            GameObject mapObj = GameObject.Find("Map");
            if (mapObj != null)
            {
                mapRenderer = mapObj.GetComponent<SpriteRenderer>();
            }
            
            if (mapRenderer == null)
            {
                Debug.LogError("Map не знайдена! Створюю нову...");
                GameObject mapObj = new GameObject("Map");
                mapRenderer = mapObj.AddComponent<SpriteRenderer>();
                
                // Завантажуємо карту з Resources
                Sprite mapSprite = Resources.Load<Sprite>("Maps/map");
                if (mapSprite != null)
                {
                    mapRenderer.sprite = mapSprite;
                    mapRenderer.size = new Vector2(20, 15); // Масштабуємо карту
                }
                else
                {
                    // Якщо карти немає, створюємо кольоровий sprite
                    mapRenderer.sprite = CreateColoredSprite(new Color(0.2f, 0.2f, 0.2f));
                    mapRenderer.size = new Vector2(20, 15);
                    Debug.LogWarning("Карта не завантажена! Переконайтеся, що файл map.png знаходиться в Assets/Resources/Maps/");
                }
                
                mapObj.transform.position = new Vector3(0, 0, 1);
            }
        }
        
        // Встановлюємо позицію карти
        if (mapRenderer != null)
        {
            mapRenderer.transform.position = new Vector3(0, 0, 1);
        }
    }
    
    private void SetupWorldMap()
    {
        if (worldMap == null)
        {
            // Шукаємо WorldMap
            GameObject worldMapObj = GameObject.Find("WorldMap");
            if (worldMapObj != null)
            {
                worldMap = worldMapObj.GetComponent<WorldMap>();
            }
            
            if (worldMap == null)
            {
                Debug.LogError("WorldMap не знайдений! Створюю новий...");
                GameObject worldMapObj = new GameObject("WorldMap");
                worldMap = worldMapObj.AddComponent<WorldMap>();
            }
        }
    }
    
    /// <summary>
    /// Створюємо кольоровий sprite для відладки
    /// </summary>
    private Sprite CreateColoredSprite(Color color)
    {
        Texture2D texture = new Texture2D(32, 32);
        for (int x = 0; x < texture.width; x++)
        {
            for (int y = 0; y < texture.height; y++)
            {
                texture.SetPixel(x, y, color);
            }
        }
        texture.Apply();
        return Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), Vector2.one * 0.5f);
    }
}
