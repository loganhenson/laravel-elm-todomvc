<?php

namespace Tests\Feature;

use App\Models\Todo;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TodosTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function can_create_todo()
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->post(route('todos.store'), [
                'description' => 'test',
            ])
            ->assertRedirect(route('home'));

        $this->assertDatabaseHas(Todo::class, [
            'user_id' => $user->id,
            'description' => 'test',
        ]);

        $this->get(route('home'))->assertJsonCount(1, 'props.todos');
    }
}
