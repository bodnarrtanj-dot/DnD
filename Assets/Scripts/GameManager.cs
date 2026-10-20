using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// Головний менеджер гри
/// Керує станом гри, завантаженням сцен тощо
/// </summary>
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    
    [Header("Налаштування гри")]
    [SerializeField] private string mainSceneName = "MainScene";
    [SerializeField] private string characterCreationSceneName = "CharacterCreation";
    [SerializeField] private string combatSceneName = "CombatScene";
    [SerializeField] private string worldSceneName = "WorldScene";
    
    public enum GameState { CharacterCreation, World, Combat, Dungeon, GameOver }
    public GameState CurrentState { get; private set; }
    
    // Посилання на інші системи
    private DiceSystem diceSystem;
    private CombatSystem combatSystem;
    private WorldMap worldMap;
    
    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        
        Instance = this;
        DontDestroyOnLoad(gameObject);
        
        // Знаходимо інші системи
        diceSystem = FindObjectOfType<DiceSystem>();
        combatSystem = FindObjectOfType<CombatSystem>();
        worldMap = FindObjectOfType<WorldMap>();
    }
    
    private void Start()
    {
        // Починаємо з створення персонажа
        ChangeState(GameState.CharacterCreation);
    }
    
    /// <summary>
    /// Зміна стану гри
    /// </summary>
    public void ChangeState(GameState newState)
    {
        CurrentState = newState;
        
        switch (newState)
        {
            case GameState.CharacterCreation:
                Debug.Log("Стан гри: Створення персонажа");
                SceneManager.LoadScene(characterCreationSceneName);
                break;
                
            case GameState.World:
                Debug.Log("Стан гри: Дослідження світу");
                SceneManager.LoadScene(worldSceneName);
                break;
                
            case GameState.Combat:
                Debug.Log("Стан гри: Бій");
                SceneManager.LoadScene(combatSceneName);
                break;
                
            case GameState.Dungeon:
                Debug.Log("Стан гри: Данж");
                // Зараз використовуємо світову сцену для данжів
                SceneManager.LoadScene(worldSceneName);
                break;
                
            case GameState.GameOver:
                Debug.Log("Стан гри: Кінець гри");
                // Можете завантажити сцену GameOver або показати UI
                break;
        }
    }
    
    /// <summary>
    /// Почати нову гру
    /// </summary>
    public void StartNewGame()
    {
        Debug.Log("Початок нової гри...");
        ChangeState(GameState.CharacterCreation);
    }
    
    /// <summary>
    /// Завантажити гру
    /// </summary>
    public void LoadGame()
    {
        Debug.Log("Завантаження гри...");
        // Тут буде логіка завантаження
        ChangeState(GameState.World);
    }
    
    /// <summary>
    /// Зберегти гру
    /// </summary>
    public void SaveGame()
    {
        Debug.Log("Збереження гри...");
        // Тут буде логіка збереження
    }
    
    /// <summary>
    /// Вийти з гри
    /// </summary>
    public void QuitGame()
    {
        Debug.Log("Вихід з гри...");
        #if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
        #else
            Application.Quit();
        #endif
    }
    
    // Методи для доступу до систем
    public DiceSystem GetDiceSystem() => diceSystem;
    public CombatSystem GetCombatSystem() => combatSystem;
    public WorldMap GetWorldMap() => worldMap;
}
