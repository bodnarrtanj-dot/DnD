using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// Карта світу з локаціями з вашої карти
/// Містить міста, данжі, ліси, гори тощо
/// </summary>
public class WorldMap : MonoBehaviour
{
    [Header("Налаштування карти")]
    [SerializeField] private Texture2D worldMapTexture;
    [SerializeField] private float mapScale = 1f;
    
    [Header("Локації на карті")]
    [SerializeField] private List<Location> locations = new List<Location>();
    
    [System.Serializable]
    public class Location
    {
        public string name;
        public string description;
        public LocationType type;
        public Vector2 position; // Позиція на карті в пікселях
        public GameObject prefab; // Префаб для відображення на карті
    }
    
    public enum LocationType { City, Dungeon, Forest, Mountain, Water, Road }
    
    private void Start()
    {
        // Ініціалізуємо локації з вашої карти
        InitializeLocations();
        
        // Завантажуємо карту
        if (worldMapTexture == null)
        {
            // Спробуємо завантажити з Resources
            worldMapTexture = Resources.Load<Texture2D>("Maps/map");
        }
    }
    
    private void InitializeLocations()
    {
        // Очищаємо список
        locations.Clear();
        
        // Додаємо локації з вашої карти (координати в пікселях)
        // Примітка: Ці координати потрібно налаштувати під ваше зображення!
        locations.Add(new Location {
            name = "Kingdom of Kerinmor",
            description = "Столиця імперії. Велике місто з фортецею.",
            type = LocationType.City,
            position = new Vector2(200, 120)
        });
        
        locations.Add(new Location {
            name = "Kingdom of Revenhold",
            description = "Друге за величиною королівство. Темне місто з таємницями.",
            type = LocationType.City,
            position = new Vector2(480, 160)
        });
        
        locations.Add(new Location {
            name = "Kamiltgon",
            description = "Південне місто. Тут ви почнете свій шлях.",
            type = LocationType.City,
            position = new Vector2(320, 480)
        });
        
        locations.Add(new Location {
            name = "Cave of Kaplos",
            description = "Фінальна підземелля. Тут ховається культ Mal'gathor.",
            type = LocationType.Dungeon,
            position = new Vector2(600, 560)
        });
        
        locations.Add(new Location {
            name = "Cultist Camp",
            description = "Табір культистів. Небезпечне місце.",
            type = LocationType.Dungeon,
            position = new Vector2(280, 240)
        });
        
        locations.Add(new Location {
            name = "Kamiltgon Dungeon",
            description = "Підземелля під Kamiltgon. Повне пасток.",
            type = LocationType.Dungeon,
            position = new Vector2(560, 360)
        });
        
        locations.Add(new Location {
            name = "Livnoya Forest",
            description = "Густий ліс. Можливі випадкові зустрічі.",
            type = LocationType.Forest,
            position = new Vector2(100, 200)
        });
        
        locations.Add(new Location {
            name = "Ginsk Mountains",
            description = "Високі гори. Прохід важкий.",
            type = LocationType.Mountain,
            position = new Vector2(600, 80)
        });
        
        locations.Add(new Location {
            name = "Homsome River",
            description = "Широка річка. Можна переплисти за додаткову дію.",
            type = LocationType.Water,
            position = new Vector2(160, 400)
        });
    }
    
    /// <summary>
    /// Отримати інформацію про локацію за координатами
    /// </summary>
    public Location GetLocationAtPosition(Vector2 position, float radius = 30f)
    {
        foreach (var location in locations)
        {
            if (Vector2.Distance(position, location.position) <= radius)
            {
                return location;
            }
        }
        return null;
    }
    
    /// <summary>
    /// Отримати всі локації певного типу
    /// </summary>
    public List<Location> GetLocationsByType(LocationType type)
    {
        List<Location> result = new List<Location>();
        foreach (var location in locations)
        {
            if (location.type == type)
            {
                result.Add(location);
            }
        }
        return result;
    }
    
    /// <summary>
    /// Малювання карти (викликається з CameraController)
    /// </summary>
    public void DrawMap(Camera camera)
    {
        if (worldMapTexture == null) return;
        
        // Малюємо карту
        // (Це робитиме CameraController або окремий рендерер)
    }
}
