<?php

namespace Tests\Feature;

use App\Models\Todo;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TodoTest extends TestCase
{
    use RefreshDatabase;

    public function test_unauthenticated_user_cannot_access_todos(): void
    {
        $response = $this->get('/todos');
        $response->assertRedirect('/login');
    }

    public function test_authenticated_user_can_view_todos_page(): void
    {
        $user = User::factory()->create();
        
        $response = $this->actingAs($user)->get('/todos');
        $response->assertStatus(200);
    }

    public function test_user_can_create_todo(): void
    {
        $user = User::factory()->create();
        
        $response = $this->actingAs($user)
            ->post('/todos', ['text' => 'Test todo']);
        
        $response->assertRedirect('/todos');
        $this->assertDatabaseHas('todos', [
            'text' => 'Test todo',
            'completed' => false,
            'user_id' => $user->id,
        ]);
    }

    public function test_user_can_update_todo(): void
    {
        $user = User::factory()->create();
        $todo = Todo::factory()->create([
            'user_id' => $user->id,
            'text' => 'Original text',
            'completed' => false,
        ]);
        
        $response = $this->actingAs($user)
            ->patch("/todos/{$todo->id}", [
                'text' => 'Updated text',
                'completed' => true,
            ]);
        
        $response->assertRedirect('/todos');
        $this->assertDatabaseHas('todos', [
            'id' => $todo->id,
            'text' => 'Updated text',
            'completed' => true,
        ]);
    }

    public function test_user_can_delete_todo(): void
    {
        $user = User::factory()->create();
        $todo = Todo::factory()->create(['user_id' => $user->id]);
        
        $response = $this->actingAs($user)
            ->delete("/todos/{$todo->id}");
        
        $response->assertRedirect('/todos');
        $this->assertDatabaseMissing('todos', ['id' => $todo->id]);
    }

    public function test_user_cannot_access_other_users_todos(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();
        $todo = Todo::factory()->create(['user_id' => $user1->id]);
        
        $response = $this->actingAs($user2)
            ->patch("/todos/{$todo->id}", ['completed' => true]);
        
        $response->assertStatus(404);
    }

    public function test_user_can_toggle_all_todos(): void
    {
        $user = User::factory()->create();
        Todo::factory()->create(['user_id' => $user->id, 'completed' => false]);
        Todo::factory()->create(['user_id' => $user->id, 'completed' => false]);
        
        $response = $this->actingAs($user)
            ->post('/todos/toggle-all', ['completed' => true]);
        
        $response->assertRedirect('/todos');
        $this->assertEquals(2, $user->todos()->where('completed', true)->count());
    }

    public function test_user_can_clear_completed_todos(): void
    {
        $user = User::factory()->create();
        Todo::factory()->create(['user_id' => $user->id, 'completed' => true]);
        Todo::factory()->create(['user_id' => $user->id, 'completed' => true]);
        Todo::factory()->create(['user_id' => $user->id, 'completed' => false]);
        
        $response = $this->actingAs($user)
            ->delete('/todos/clear-completed');
        
        $response->assertRedirect('/todos');
        $this->assertEquals(1, $user->todos()->count());
        $this->assertEquals(0, $user->todos()->where('completed', true)->count());
    }

    public function test_todo_validation_requires_text(): void
    {
        $user = User::factory()->create();
        
        $response = $this->actingAs($user)
            ->post('/todos', ['text' => '']);
        
        $response->assertSessionHasErrors('text');
    }

    public function test_todo_text_has_max_length(): void
    {
        $user = User::factory()->create();
        
        $response = $this->actingAs($user)
            ->post('/todos', ['text' => str_repeat('a', 256)]);
        
        $response->assertSessionHasErrors('text');
    }
}