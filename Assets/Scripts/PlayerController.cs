using UnityEngine;

/// <summary>
/// Контролер гравця для D&D гри
/// Керування: WASD або стрілки
/// </summary>
public class PlayerController : MonoBehaviour
{
    [Header("Налаштування руху")]
    [SerializeField] private float moveSpeed = 5f;
    [SerializeField] private float rotationSpeed = 10f;
    
    [Header("Налаштування камери")]
    [SerializeField] private Camera mainCamera;
    
    [Header("Налаштування кубиків")]
    [SerializeField] private int diceRollDistance = 3; // Кількість клітинок для руху при кидку d6
    
    private Rigidbody2D rb;
    private Vector2 movement;
    private Vector2 mousePosition;
    private DiceSystem diceSystem;
    
    private void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        diceSystem = FindObjectOfType<DiceSystem>();
        if (mainCamera == null)
            mainCamera = Camera.main;
    }
    
    private void Update()
    {
        // Отримуємо ввід з клавіатури
        movement.x = Input.GetAxisRaw("Horizontal");
        movement.y = Input.GetAxisRaw("Vertical");
        
        // Обробка кидка кубика (Пробіл)
        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (diceSystem != null)
            {
                int roll = diceSystem.RollD6();
                Debug.Log($